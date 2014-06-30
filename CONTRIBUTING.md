# CONTRIBUTING

The Buttercoin project welcomes new contributors.  This document will guide you
through the process.


### FORK

Fork the project [on GitHub](https://github.com/buttercoin) and check out
your copy.

Now decide if you want your feature or bug fix to go into the master branch
or a feature branch.  As a rule of thumb, bug fixes go into the master branch
while new features go into the feature branch.

Buttercoin has several dependencies that are not part of the project proper. Any changes to the code for these dependancies should be sent to their respective
projects.  Do not send your patch to us, we cannot accept it.

In case of doubt, open an issue in the [issue tracker][], post your question
to [Reddit](http://www.reddit.com/r/buttercoin) or contact one of the [project maintainers][]
on [IRC][].

Especially do so if you plan to work on something big.  Nothing is more
frustrating than seeing your hard work go to waste because your vision
does not align with that of a project maintainer.

### BRANCH

Okay, so you have decided on the proper branch.  Create a feature branch
and start hacking:

```
$ git checkout -b my-feature-branch -t origin
```

### COMMIT

Make sure git knows your name and email address:

```
$ git config --global user.name "FirstName LastName"
$ git config --global user.email "you@example.com"
```

Writing good commit logs is important.  A commit log should describe what
changed and why.  Follow these guidelines when writing one:

1. The first line should be 50 characters or less and contain a short
   description of the change prefixed with the name of the changed
   subsystem (e.g. "net: add localAddress and localPort to Socket").
2. Keep the second line blank.
3. Wrap all other lines at 72 columns.

A good commit log looks like this:

```
subsystem: explaining the commit in one line

Body of commit message is a few lines of text, explaining things
in more detail, possibly giving some background about the issue
being fixed, etc etc.

The body of the commit message can be several paragraphs, and
please do proper word-wrap and keep columns shorter than about
72 characters or so. That way `git log` will show things
nicely even when it is indented.
```

The header line should be meaningful; it is what other people see when they
run `git shortlog` or `git log --oneline`.

Check the output of `git log --oneline files_that_you_changed` to find out
what subsystem (or subsystems) your changes touch.


### REBASE

Use `git rebase` (not `git merge`) to sync your work from time to time.

```
$ git fetch upstream
$ git rebase upstream/master
```


### TEST

Bug fixes and features should come with tests.  Add your tests in the
test/ directory.  Look at other tests to see how they should be
structured (license boilerplate, common includes, etc.).

### PUSH

```
$ git push origin my-feature-branch
```

Go to https://github.com/username/buttercoin and select your feature branch.  Click
the 'Pull Request' button and fill out the form.

Pull requests are usually reviewed within a few days.  If there are comments
to address, apply your changes in a separate commit and push that to your
feature branch.  Post a comment in the pull request afterwards; GitHub does
not send out notifications when you add commits.

[issue tracker]: https://github.com/buttercoin/buttercoin/issues
[IRC]: http://webchat.freenode.net/?channels=buttercoin
[project maintainers]: https://github.com/buttercoin/buttercoin/wiki/Project-Organization
