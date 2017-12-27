if [[ "$refname" == refs/tags/* ]]; then
    # Do the split!
    PARENT_TAG=${refname:10}
    bash split.sh $PARENT_TAG $GITHUB_TOKEN
else
    echo "Split occurs only in a tag run"
fi