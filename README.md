# Git Subrepository Split

## Post-Receive Hook

The repository split is triggered on a git post-receive hook. When triggered,
the split should occur only when a new version in the parent repository has been
tagged. This is done by checking to see if the git reference is a tag:

```sh
if [[ "$refname" == refs/tags/* ]]; then
    # Do the split!
    PARENT_TAG=${refname:10}
    bash split.sh $PARENT_TAG $GITHUB_TOKEN
else
    echo "Split occurs only in a tag run"
fi
```

## Subtree Split

The command [git subtree split](http://git-memo.readthedocs.io/en/latest/subtree.html)
is used to separate one repository into multiple repositories. The third party
library [splitsh](https://github.com/splitsh/lite) is useful for easily creating
a subtree split from a git project and pushing to a github repository.

```sh
$ git fetch --unshallow
$ split sub/directory "$USER/$REPO.git"
```

The command `git fetch --unshallow` ensures the entire commit history is used
for the split.

## Versioning

In the directory which serves the root of the subrepository, a `VERSION` file is
used to track the tagged version of the sub repository.

$ cat sub/directory/VERSION
0.1.0

When the subtree split occurs, the version file should be used to tag the
repository. If the tag specified in the VERSION file doesn’t exist, it should be
created.

```sh
if curl -f https://api.github.com/repos/$USER/$REPO/releases/tags/v0.1.0 \
  -H "Authorization: Bearer $GITHUB_TOKEN" >> /dev/null; then
    curl https://api.github.com/repos/grpc/grpc-php/releases \
        -d 'tag_name=v0.1.0' \
        -d 'name=Subrepository Split v0.1.0' \
        -d 'body=For release notes, please see [$USER/$REPO](https://github.com/$USER/$REPO/releases/tag/$PARENT_TAG)'
        -H "Authorization: Bearer $GITHUB_TOKEN"
fi
```

In the above example, the subrepository release links back to the parent release
which triggered it.

## Examples

 * [Triggering a split for Travis CI](https://github.com/GoogleCloudPlatform/google-cloud-php/blob/3e21b68005e89205ffc1cda9c46fc1fb879ee056/dev/sh/trigger-split)
 * [.travis.yaml for triggering a split](https://github.com/GoogleCloudPlatform/google-cloud-php/blob/7b05f81e67348ec3a5c70ae7716db55499ca18f0/.travis.yml#L34)
 * [Compiling Splitsh](https://github.com/GoogleCloudPlatform/google-cloud-php/blob/3e21b68005e89205ffc1cda9c46fc1fb879ee056/dev/sh/compile-splitsh)
 * [Checking and creating a release](https://github.com/GoogleCloudPlatform/google-cloud-php/blob/3e21b68005e89205ffc1cda9c46fc1fb879ee056/dev/src/Split/Command/Split.php#L142)
