docker-js
=========
> Personal docker image for JS projects.

# Build
```
docker build -t p1100i/js .
```

# Push
```
docker push p1100i/js
```

# Local use
```
docker run                              \
  --tty                                 \
  --interactive                         \
  --rm                                  \
  --privileged                          \
  --volume "$(pwd):/builds/project"     \
  --env SKIP_NPM_INSTALL="true"         \
  p1100i/js
```

# Gitlab use
Have the `.gitlab-ci.yml` file for your project with the following content:
```
image:
  name: p1100i/js
```
Everything should be automated by [entrypoint.sh](entrypoint.sh) handling [variables predefined](https://docs.gitlab.com/ee/ci/variables/predefined_variables.html) by the gitlab runner env.
