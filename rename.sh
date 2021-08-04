#!/bin/bash

find . | grep -P "(\.(rb|gemspec|md|yaml|yml|ru)|(bin\/console))$" | xargs sed -i -e "s/Rapid/Apia/" $1
find . | grep -P "(\.(rb|gemspec|md|yaml|yml|ru)|(bin\/console))$" | xargs sed -i -e "s/rapid/apia/" $1

if [ -f "rapid.gemspec" ]; then
  mv rapid.gemspec apia.gemspec
fi

if [ -d "lib/rapid" ]; then
  mv lib/rapid lib/apia
fi

if [ -f "lib/rapid.rb" ]; then
  mv lib/rapid.rb lib/apia.rb
fi

if [ -d "spec/specs/rapid" ]; then
  mv spec/specs/rapid spec/specs/apia
fi
