## TODO: Replace this path when there is a latest release
MERLIN_DL="https://github.com/yutila-org/merlin/archive/refs/tags/alpha.tar.gz"

curl -sSL $MERLIN_DL --output ./merlin.tar.gz
tar -xf ./merlin.tar.gz
rm merlin.tar.gz

# TODO: Find a way to get the folder's name in the archiver
MERLIN="merlin-alpha"

make -C ./$MERLIN/
cp ./$MERLIN/bin/merlin ./
rm -r ./$MERLIN
