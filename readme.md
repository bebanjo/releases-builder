# Releases Builder

This script will create a Jekyll post from the body of an issue. 

The script has an endpoint triggered by GitHub `issue` webhook:

```sh
$ curl -X POST https://yourdomain.com/ping
```

The issue must also have the tag `column:release` and `frontmatter` like this:

```md
---

title: Title of the release note
date: YYYY-MM-DD HH:MM:SS 
updated: YYYY-MM-DD HH:MM:SS
revision: 1

---

Description of the release note.

## References

- `repo#number` Title of the referenced issue
```

## Install

1. `git clone git@github.com:bebanjo/releases-builder.git` and `cd releases-builder`
2. `cp .env-sample .env`, edit and [get a personal token (repo access)](https://github.com/settings/tokens/new)
3. Install dependencies with `bundle install`
4. Run the application with `foreman start web` e.g. `-> https://releases-builder.herokuapp.com`
5. The repo you want to create releases needs a webhook e.g. `https://github.com/<user>/<repo>/settings/hooks`
6. Point the webhook to your ping URL e.g. `https://releases-builder.herokuapp.com/ping`
