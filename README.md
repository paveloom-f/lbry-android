# About this fork

This fork disables the filter of black-listed content used in the official [LBRY Android](https://github.com/lbryio/lbry-android) client by changing a few lines of code. Specifically, by applying

```bash
sed -ri 's|(Lbryio\.populateOutpointList)|// \1|g' "$(grep -lr "Lbryio.populateOutpointList" app/src)"
```

in the [build process](https://github.com/paveloom-f/lbry-android/actions).

It is a proof-of-concept piece of software, and users running it may put themselves at legal risk.

The APKs are available on the [Releases](https://github.com/paveloom-f/lbry-android/releases/) page.

Git mirrors:
- [Codeberg](https://codeberg.org/paveloom-f/lbry-android)
- [GitHub](https://github.com/paveloom-f/lbry-android)
- [GitLab](https://gitlab.com/paveloom-g/forks/lbry-android)

See also:
- [LBRY Desktop Fork](https://github.com/paveloom-f/lbry-desktop)

Learn more about:
- [DMCA policy](https://lbry.com/faq/dmca)
- [Content policy](https://lbry.com/faq/content)
- [Current DMCA takedowns](https://github.com/lbryio/dmca)
