# Release Builder

This script will create a Jekyll post from the body of an issue.
The issue must have the tag `column:acceptance` and `frontmatter` like this:

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
