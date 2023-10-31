# frozen_string_literal: true

module Apia
  module OpenAPI
    class Schema

      def initialize(api, base_url)
        @api = api
        @base_url = base_url # TODO: should we support multiple urls?
        @spec = {
          openapi: '3.1.0',
          info: {},
          servers: [],
          paths: {},
          components: {
            schemas: {}
          },
          security: []
        }
        build_spec
      end

      def json
        JSON.pretty_generate(@spec)# .to_json
      end

      private

      def build_spec
        add_info
        add_servers
        add_paths
        add_security
      end

      def add_info
        @spec[:info] = {
          version: "1.0.0", # TODO can we actually read the api version?
          title: @api.definition.name || @api.definition.id
        }
        @spec[:info][:description] = @api.definition.description unless @api.definition.description.nil?
      end

      def add_servers
        @spec[:servers] << { url: @base_url }
      end

      def add_paths
        @api.definition.route_set.routes.each do |route|
          next unless route.endpoint.definition.schema? # not all routes should be documented

          path = route.path
          route_spec = { operationId: "#{route.request_method}:#{path}" }
          if route.request_method == :get
            add_parameters(route, route_spec)
          else
            add_request_body(route, route_spec)
          end

          @spec[:paths]["/#{path}"] ||= {}
          @spec[:paths]["/#{path}"]["#{route.request_method.to_s}"] = route_spec

          add_responses(route, route_spec)
        end
      end

      # aka query params
      def add_parameters(route, route_spec)
        route_spec[:parameters] ||= []

        route.endpoint.definition.argument_set.definition.arguments.each_value do |arg|
          if arg.type.argument_set?
            # complex argument sets are not supported in query params (e.g. nested objects)
            arg.type.klass.definition.arguments.each_value do |child_arg|
              param = {
                name: "#{arg.name.to_s}[#{child_arg.name.to_s}]",
                in: "query",
                schema: {
                  type: convert_type_to_openapi_data_type(child_arg.type)
                }
              }
              route_spec[:parameters] << param
            end
          elsif arg.array?
            if arg.type.enum? || arg.type.object? # polymorph?
              items = { "$ref": "#/components/schemas/#{generate_id(arg.type.klass.definition)}" }
              add_component_schema(arg)
            else
              items = { type: convert_type_to_openapi_data_type(arg.type) }
            end

            param = {
              name: "#{arg.name}[]",
              in: "query",
              schema: {
                type: "array",
                items: items
              }
            }
            route_spec[:parameters] << param
          elsif arg.type.enum?
            param = {
              name: arg.name.to_s,
              in: "query",
              schema: {
                "$ref": "#/components/schemas/#{generate_id(arg.type.klass.definition)}"
              }
            }
            route_spec[:parameters] << param
            add_component_schema(arg)
          else
            param = {
              name: arg.name.to_s,
              in: "query",
              schema: {
                type: convert_type_to_openapi_data_type(arg.type)
              }
            }
            route_spec[:parameters] << param
          end
        end
      end

      def add_component_schema(definition)
        id = generate_id(definition.type.klass.definition)
        return unless @spec.dig(:components, :schemas, id).nil?

        component_schema = {}
        @spec[:components][:schemas][id] = component_schema
        generate_schema(definition: definition, schema: component_schema)
      end

      # We generate schemas for two reasons:
      # 1. to add them to the components section (so they can be referenced)
      # 2. to add them to the request body when not all fields are returned in the response
      def generate_schema(definition:, schema: ,endpoint: nil, path: nil)
        if definition.type.polymorph?
          schema[:type] = 'object'
          schema[:properties] ||= {}
          refs = []
          definition.type.klass.definition.options.map do |name, polymorph_option|
            refs << { "$ref": "#/components/schemas/#{generate_id(polymorph_option.type.klass.definition)}" }
            add_component_schema(polymorph_option)
          end
          schema[:properties][definition.name.to_s] = { oneOf: refs }
          return schema
        elsif definition.respond_to?(:array?) && definition.array?
          schema[:type] = 'object'
          schema[:properties] ||= {}
          if definition.type.argument_set? || definition.type.enum? || definition.type.object?
            if definition.type.argument_set? # TODO add array of argument sets to the example app (refer to CoreAPI::ArgumentSets::KeyValue)
              children = definition.type.klass.definition.arguments.values
            else
              children = definition.type.klass.definition.fields.values
            end
          else
            items = { type: convert_type_to_openapi_data_type(definition.type) }
          end

          if items
            schema[:properties][definition.name.to_s] = {
              type: "array",
              items: items
            }
            return schema
          end
        end

        if definition.type.argument_set?
          children = definition.type.klass.definition.arguments.values
        elsif definition.type.object?
          children = definition.type.klass.definition.fields.values
        elsif definition.type.enum?
          children = definition.type.klass.definition.values.values
        else
          children = []
        end

        # if !definition.type.enum? && !endpoint.nil?
        #   puts "definition.type #{definition.type.klass}"
        #   puts "children: #{children.map { |c| [c.name, endpoint.include_field?(path + [c.name])] }}"
        #   puts "children.all? #{children.all? { |child| endpoint.include_field?(path + [child.name]) }}"
        #   puts ""
        # end
        all_properties_included = definition.type.enum? || endpoint.nil? #|| children.all? { |child| endpoint.include_field?(path + [child.name]) }
        #puts "all_properties_included: #{all_properties_included}"

        children.each do |child|
          next unless endpoint.nil? || (!definition.type.enum? && endpoint.include_field?(path + [child.name]))

          if definition.type.enum?
            schema[:type] = 'string'
            schema[:enum] = children.map { |c| c[:name] }
          elsif child.type.argument_set? || child.type.enum? || child.type.polymorph?
            schema[:type] = 'object'
            schema[:properties] ||= {}
            schema[:properties][child.name.to_s] = {
              "$ref": "#/components/schemas/#{generate_id(child.type.klass.definition)}"
            }
            add_component_schema(child)
          elsif child.type.object?
            schema[:type] = 'object'
            schema[:properties] ||= {}
            # In theory we could point to a ref here if * is used to include all fields of a child object, but we'd
            # need to parse the endpoint include string to determine if that's the case.
            if all_properties_included
              schema[:properties][child.name.to_s] = {
                "$ref": "#/components/schemas/#{generate_id(child.type.klass.definition)}"
              }
              add_component_schema(child)
            else
              child_path = path.nil? ? nil : path + [child]
              child_schema = {}
              schema[:properties][child.name.to_s] = child_schema
              generate_schema(definition: child, schema: child_schema, endpoint: endpoint, path: child_path)
            end
          else
            schema[:type] = 'object'
            schema[:properties] ||= {}
            schema[:properties][child.name.to_s] = {
              type: convert_type_to_openapi_data_type(child.type)

            }
          end
        end

        schema
      end

      # TODO: can you use a polymorph in a request body?
      def add_request_body(route, route_spec)
        properties = {}
        route.endpoint.definition.argument_set.definition.arguments.each_value do |arg|
          id = generate_id(arg.type.klass.definition)
          if arg.array?
            if arg.type.argument_set? || arg.type.enum?
              items = { "$ref": "#/components/schemas/#{id}" }
              add_component_schema(arg)
            else
              items = { type: convert_type_to_openapi_data_type(arg.type) }
            end

            properties[arg.name.to_s] = {
              type: "array",
              items: items
            }
          elsif arg.type.argument_set? || arg.type.enum?
            properties[arg.name.to_s] = {
              "$ref": "#/components/schemas/#{id}"
            }
            add_component_schema(arg)
          else # scalar
            properties[arg.name.to_s] = {
              type: convert_type_to_openapi_data_type(arg.type)
            }
          end

        end

        # TODO: description
        # TODO: required
        route_spec[:requestBody] = {
          content: {
            "application/json": {
              schema: {
                properties: properties
              }
            }
          }
        }
      end

      def add_responses(route, route_spec)
        properties = {}
        route.endpoint.definition.fields.each do |name, field|
          properties.merge!(
            generate_properties_for_response(name, field, route.endpoint)
          )
        end

        schema = {
          properties: properties
        }

        required_fields = route.endpoint.definition.fields.select { |name, field| field.condition.nil? }
        schema[:required] = required_fields.keys if required_fields.any?

        route_spec[:responses] = {
          "#{route.endpoint.definition.http_status}": {
            description: route.endpoint.definition.description || "",
            content: {
              "application/json": {
                schema: schema
              }
            }
          }
        }
      end

      # Response fields can often just point to a ref of a schema. But it's also
      # possible to reference a return type and not include all fields of that type.
      # The presence of the `include` keyword arg defines which fields are included.
      def generate_properties_for_response(name, field, endpoint)
        properties = {}
        if field.type.polymorph?
          if field.include.nil?
            refs = []
            field.type.klass.definition.options.map do |name, polymorph_option|
              refs << { "$ref": "#/components/schemas/#{generate_id(polymorph_option.type.klass.definition)}" }
              add_component_schema(polymorph_option)
            end
            properties[name] = { oneOf: refs }
          else
            # TODO
          end
        elsif field.array?
          if field.type.object? || field.type.enum? # polymorph?
            if field.include.nil?
              items = { "$ref": "#/components/schemas/#{generate_id(field.type.klass.definition)}" }
              add_component_schema(field)
            else
              array_schema = {}
              generate_schema(definition: field, schema: array_schema, endpoint: endpoint, path: [field])
              if array_schema[:properties].any?
                items = array_schema
              end
            end
          else
            items = { type: convert_type_to_openapi_data_type(field.type) }
          end
          if items
            properties[name] = {
              type: "array",
              items: items
            }
          end
        elsif field.type.object? || field.type.enum?
          if field.include.nil?
            properties[name] = {
              "$ref": "#/components/schemas/#{generate_id(field.type.klass.definition)}"
            }
            add_component_schema(field)
          else
            object_schema = {}
            generate_schema(definition: field, schema: object_schema, endpoint: endpoint, path: [field])
            properties[name] = object_schema
          end
        else # scalar
          properties[name] = {
            type: convert_type_to_openapi_data_type(field.type)
          }
        end
        properties
      end

      def add_security
        @api.objects.select { |o| o.ancestors.include?(Apia::Authenticator) }.each do |authenticator|
          next unless authenticator.definition.type == :bearer

          @spec[:components][:securitySchemes] ||= {}
          @spec[:components][:securitySchemes][generate_id(authenticator.definition)] = {
            scheme: 'bearer',
            type: "http",
          }

          @spec[:security] << {
            generate_id(authenticator.definition) => []
          }
        end
      end

      # forward slashes do not work in ids (e.g. schema ids)
      def generate_id(definition)
        definition.id.gsub(/\//, '_')
      end

      def convert_type_to_openapi_data_type(type)
        if type.klass == Apia::Scalars::UnixTime
          'integer'
        elsif type.klass == Apia::Scalars::Decimal
          'number'
        elsif type.klass == Apia::Scalars::Base64
          'string'
        else
          type.klass.definition.name.downcase
        end
      end
    end
  end
end
