USING: destructors kernel llvm.wrappers sequences tools.test vocabs ;

[ ] [ "test" <module> dispose ] unit-test
[ ] [ "test" <module> <provider> dispose ] unit-test
[ ] [ "llvm.jit" vocabs member? [ "test" <module> <provider> <engine> dispose ] unless ] unit-test