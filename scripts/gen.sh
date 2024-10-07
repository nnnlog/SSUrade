cd ./packages/application
dart run build_runner build
cd -

cd ./packages/adaptor
dart run build_runner build
cd -

cd ./packages/bloc
dart run build_runner build
cd -

dart run build_runner build
