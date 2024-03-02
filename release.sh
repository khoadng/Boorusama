# Get the version from pubspec.yaml
version=$(head -n 5 pubspec.yaml | tail -n 1 | cut -d ' ' -f 2)

# Remove the build number from the version e.g. 1.0.0+1 to 1.0.0
version=$(echo $version | cut -d + -f 1)

# Echo the git steps
echo "Creating a new git tag v$version"
git tag -a v$version -m "Release $version"

# Push the git tag
echo "Pushing the git tag"
git push --tags

# Build the appbundle for the prod flavor
echo "Building the appbundle for the prod flavor"
./appbundle.sh prod

