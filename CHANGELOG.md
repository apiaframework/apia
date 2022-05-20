# Apia CHANGELOG

This file contains all the latest changes and updates to Apia.

## 3.1.0

### Features

- add ArgumentSet#empty? ([7ecb02](https://github.com/krystal/apia/commit/7ecb0252571250620070f8355904725a344b9959))
- add notifications ([af932d](https://github.com/krystal/apia/commit/af932dc452d002bcabd4b8afa58f1eded9551c5a))

### Bug Fixes

- ensure non-hash JSON bodies are converted to empty hashes ([1c7efc](https://github.com/krystal/apia/commit/1c7efcdcd11379e9bdfabc853eed20feee90743a))

## 3.0.3

### Features

- allow both URL params and JSON at the same time ([fb1b36](https://github.com/krystal/apia/commit/fb1b36d2b1388d43c1360b0be413611dc0adce5a))

## 3.0.2

## 3.0.1

### Features

- allow route groups to be excluded from the schema ([9df32d](https://github.com/krystal/apia/commit/9df32d02704378f50f7e294a7616de24ce65fdcb))

## 3.0.0

## 2.0.0

## 2.0.0-alpha.3

## 2.0.0-alpha.2

### Bug Fixes

- fixes errors in endpoints, improve call consistency ([f95bad](https://github.com/krystal/apia/commit/f95bad7e34ec01b809adaaaa985ebbe1df82b1b4))

## 2.0.0-alpha.1

### Bug Fixes

- ensure field_spec is required ([173f30](https://github.com/krystal/apia/commit/173f30857ffa870bfbc7bd610d3bc7ec84e7bfd7))

## 2.0.0-alpha.0

### Features

- add `call` to endpoint & authenticators ([9aa0b5](https://github.com/krystal/apia/commit/9aa0b55ff9b470eeb7a0bd4d80b58f343ce123b1))

## 1.2.3

### Bug Fixes

- further fix for field specs with root-level wildcards ([a0100a](https://github.com/krystal/apia/commit/a0100aabb9573a315deb3d532a6aa3fcb22c965c))

## 1.2.2

### Bug Fixes

- improve handling of wildcards in field specs ([a26ffc](https://github.com/krystal/apia/commit/a26ffc297563ace3d7b82d5363a1ccb76422e02e))

## 1.2.1

### Bug Fixes

- allow uppercase characters in argument names ([5299bc](https://github.com/krystal/apia/commit/5299bc4e4478086ebf1efadbb24513270a404863))

## 1.2.0

### Features

- add API.test to support testing endpoints ([410fd9](https://github.com/krystal/apia/commit/410fd9cbfd63de266cb99a4ddccded67cf61be3a))

## 1.1.3

### Bug Fixes

- refer to top level Set ([180557](https://github.com/krystal/apia/commit/180557f96b0ba917ede14004e6ca258239185247))
- require set, too ([dfb027](https://github.com/krystal/apia/commit/dfb027ca5e32a5e2687e17715bbe0efc08eefb7d))
- ruby 2.x compat ([3a8682](https://github.com/krystal/apia/commit/3a8682f5db07df5a750b9be6ae8907403cbcad52))
- ruby 3.0 compat ([a03c6c](https://github.com/krystal/apia/commit/a03c6c5ff34f1725465800b5e4b80854cffda0fb))

## 1.1.2

### Bug Fixes

- don't include routes for endpoints that have schema disabled ([637105](https://github.com/krystal/apia/commit/6371059dde8a4677cbb347043a27e9df9123c025))

## 1.1.1

### Bug Fixes

- execute the scope_validation within the request environment ([0e0842](https://github.com/krystal/apia/commit/0e08423efd74845a88ed69d22ee23d920fba06d5))

## 1.1.0

### Features

- scopes ([0016e5](https://github.com/krystal/apia/commit/0016e5ef6d1f2ca30a2a83526444a19b5b577822))

## 1.0.4

### Features

- add ArgumentSet#has? to say if an argument set has a value ([c0b764](https://github.com/krystal/apia/commit/c0b7643eaad5f6b3b1fbc625015d918a23bd49af))

### Bug Fixes

- fixes issue where nil couldn't be deliberately provided ([54f253](https://github.com/krystal/apia/commit/54f253b1627326287b8738802737c7e393741074))

## 1.0.3

## 1.0.2

### Bug Fixes

- return all fields for polymorphs by default ([8262a0](https://github.com/krystal/apia/commit/8262a0eba7d3c75fa3c7c5efdb061c04b72a7434))

## 1.0.1

### Bug Fixes

- return all fields when no field spec is provided ([98c1bb](https://github.com/krystal/apia/commit/98c1bbb1118028db821e3409df12ca89ff959b0b))

## 1.0.0

The initial release!
