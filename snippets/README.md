## Snippets

### How to apply config to a single cluster

```
cd ./tokyo
./provision.sh
```

### Adding a new cluster

```
# from this directory
mkdir my_snippets_region
cp ./tokyo/provision.sh ./my_snippets_region/provision.sh
# edit ./my_snippets_region/provision.sh
chmod 755 ./my_snippets_region/provision.sh 
git add ./my_snippets_region/provision.sh 
git commit
cd ./my_snippets_region
./provision.sh
```
