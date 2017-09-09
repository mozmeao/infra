Here's some things to check when MDN is in maintenance mode.

Note: Replace https://mdn-mm.moz.works with the base URL you are testing

Base URL: https://mdn-mm.moz.works

# Preparing for Maintenance Mode

If you want a public-facing site, you'll need to generate
content before putting the site in Maintenance Mode. The
full steps are in *todo*, but here's the quick version:

* [ ] Load a recent (anonymized) backup
* [ ] Enable GitHub auth (see [Enable GitHub Auth](https://kuma.readthedocs.io/en/latest/installation.html#enable-github-auth-optional))
* [ ] Render unrendered pages
* [ ] Generate the search index
* [ ] Restart web servers, etc. in Maintenance Mode

# Manual Sanity Check

## Home page

Load https://mdn-mm.moz.works/en-US

* [ ] Loads without errors
* [ ] Has banner "MDN is currently in read-only maintenance mode. Learn more."
* [ ] No login option or view profile at the top
* [ ] Has entries for the Hacks Blog

## Article page

Load https://mdn-mm.moz.works/en-US/docs/Web/HTML

* [ ] Loads without errors
* [ ] Has banner "MDN is currently in read-only maintenance mode. Learn more."
* [ ] No login option or view profile at the top

## Maintenance Mode page

Click a banner to load https://mdn-mm.moz.works/en-US/maintenance-mode

* [ ] Page is the destination of the "Learn more" link in the banner
* [ ] Loads without errors

# Automated Checks

With a Kuma environment,
[run the functional tests](https://kuma.readthedocs.io/en/latest/tests-ui.html),
using a command like:

```
py.test --maintenance-mode tests/functional --base-url https://mdn-mm.moz.works --driver Chrome --driver-path /path/to/chromedriver
```

* [ ] Functional tests pass

These check that disabled endpoints redirect to the maintenance page, and that
other pages are OK. It duplicates the Manual Sanity Check.

# Full Manual Tests

*todo*

# Background

Maintenance Mode is used to serve a recent copy of the site content, without
allowing logins or database writes. It is used when the usual database is
unavailable due to maintenance, such as a long-running migration or a
datacenter transfer.

It is enabled with the environment variable ``MAINTENANCE_MODE=True``.
More information and local development setup is in the
[Kuma documentation](https://kuma.readthedocs.io/en/latest/development.html#maintenance-mode).

It is possible, but not required, to run maintenance mode against a read-only
database.

In this mode, no one is logged in and cookies are not sent. Articles can not be
created, translated, or edited. If a page was not rendered, it can't be in
maintenance mode, and KumaScript macros will be seen in the output.

Background tasks may still be scheduled, so the celery broker should remain
available. Many tasks are completed with no action.  Others, such as sitemap
generation and cacheback refreshing, continue to run as normal.
