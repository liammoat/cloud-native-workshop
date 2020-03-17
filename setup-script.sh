echo "Cloud Native Workshop - Setup Script"

# clear existing

rm -rf ~/cnw

# clone workshop

git clone https://github.com/liammoat/cloud-native-workshop.git ./cnw
cd .\cnw\

# open workshop in code

code .