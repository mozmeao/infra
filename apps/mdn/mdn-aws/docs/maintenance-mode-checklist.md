Here's some things to check when MDN is in maintenance mode.

This checklist uses these URLs:

* Base: https://mdn-mm.moz.works
* CDN: https://mm-cdn.mdn.moz.works
* Demo: https://mdn-mm-demos.moz.works
* Interactive Examples: https://interactive-examples.mdn.moz.works

# Preparing for Maintenance Mode

If you want a public-facing site, you'll need to generate
content before putting the site in Maintenance Mode. The
full steps are in init-checklist.md, but here's the quick version:

* [ ] Load a recent (anonymized) backup
* [ ] Enable GitHub auth (optional, to use Django admin for config)
* [ ] Configure the Site
* [ ] Set required Constance values (``KUMASCRIPT_TIMEOUT``, ``KUMA_WIKI_IFRAME_ALLOWED_HOSTS``)
* [ ] Set desired Waffle flags
* [ ] Generate the search index
* [ ] Render unrendered pages (optional)
* [ ] Generate sitemaps
* [ ] Generate humans.txt
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
py.test --maintenance-mode tests/functional tests/redirects --base-url https://mdn-mm.moz.works --driver Chrome --driver-path /path/to/chromedriver
```

Some tests will fail the first time they are run against a server with cold
caches. Some tests are flakey, and will intermittantly fail.  If a test
passes once in three tries, we consider it a success.

* [ ] Functional tests pass

These check that disabled endpoints redirect to the maintenance page, and that
other pages are OK. It duplicates the Manual Sanity Check.

# Full Manual Tests

*Note: Many of these are candidates for headless testing*

* [ ] https://mdn-mm-demos.moz.works/en-US/docs/Learn/CSS/Styling_text/Fundamentals$samples/Color - 200, sample as a stand-alone page
* [ ] https://mdn-mm-demos.moz.works/files/12984/web-font-example.png - 200, PNG of some "Hipster ipsum" text
* [ ] https://mdn-mm.moz.works/@api/deki/files/3613/=hut.jpg - 200, image of a hat
* [ ] https://mdn-mm.moz.works/admin/ - Redirects to maintenance mode page
* [ ] https://mdn-mm.moz.works/contribute.json - 200, project info
* [ ] https://mdn-mm.moz.works/diagrams/workflow/workflow.svg - 200, SVG with images
* [ ] https://mdn-mm.moz.works/en-US/dashboards/macros - 200, list of macros and page counts
* [ ] https://mdn-mm.moz.works/en-US/dashboards/revisions - 200, list of recent changes
* [ ] https://mdn-mm.moz.works/en-US/dashboards/spam - Redirects to Maintenance Mode page
* [ ] https://mdn-mm.moz.works/en-US/docs/Learn/CSS/Styling_text/Fundamentals#Color - 200, with sample as iframe
* [ ] https://mdn-mm.moz.works/en-US/docs/Learn/CSS/Styling_text/Fundamentals$toc - 200, HTML table of contents
* [ ] https://mdn-mm.moz.works/en-US/docs/Web/HTML$children - 200, JSON list of child pages
* [ ] https://mdn-mm.moz.works/en-US/docs/Web/HTML$compare?locale=en-US&to=1299417&from=1293895 - 200, compares revisions
* [ ] https://mdn-mm.moz.works/en-US/docs/Web/HTML$history - 200, list of revisions
* [ ] https://mdn-mm.moz.works/en-US/docs/Web/HTML$json - 200, JSON of page metadata
* [ ] https://mdn-mm.moz.works/en-US/docs/Web/HTML$revision/1293895 - 200, historical revision
* [ ] https://mdn-mm.moz.works/en-US/docs/Web/HTML$translate - Redirect to Maintenance Mode page
* [ ] https://mdn-mm.moz.works/en-US/docs/all - 200, paginated list of docs
* [ ] https://mdn-mm.moz.works/en-US/docs/ckeditor_config.js - 200, JavaScript
* [ ] https://mdn-mm.moz.works/en-US/docs/feeds/atom/files/ - 200, Atom feed of changed files
* [ ] https://mdn-mm.moz.works/en-US/docs/feeds/rss/all/ - 200, RSS feed of new pages
* [ ] https://mdn-mm.moz.works/en-US/docs/feeds/rss/needs-review/ - 200, RSS feed of pages needing review
* [ ] https://mdn-mm.moz.works/en-US/docs/feeds/rss/needs-review/technical - 200, RSS feed of pages needing technical review
* [ ] https://mdn-mm.moz.works/en-US/docs/feeds/rss/revisions - 200, RSS feed of changes
* [ ] https://mdn-mm.moz.works/en-US/docs/feeds/rss/tag/CSS - 200, RSS feed of pages with CSS tag
* [ ] https://mdn-mm.moz.works/en-US/docs/needs-review/editorial - 200, paginated list of documents
* [ ] https://mdn-mm.moz.works/en-US/docs/tag/ARIA - 200, list of documents
* [ ] https://mdn-mm.moz.works/en-US/docs/tags - 200, paginated list of tags
* [ ] https://mdn-mm.moz.works/en-US/docs/top-level - 200, paginated list of documents
* [ ] https://mdn-mm.moz.works/en-US/docs/with-errors - 200, (empty?) paginated list of documents
* [ ] https://mdn-mm.moz.works/en-US/docs/without-parent - 200, paginated list of documents
* [ ] https://mdn-mm.moz.works/en-US/miel  - 500 Internal Server Error
* [ ] https://mdn-mm.moz.works/en-US/profiles/sheppy - 200, Sheppy's profile
* [ ] https://mdn-mm.moz.works/en-US/promote/ - 200, Promote MDN with 4 buttons
* [ ] https://mdn-mm.moz.works/en-US/search - 200, Search results
* [ ] https://mdn-mm.moz.works/fellowship/ - 200, 2015 MDN Fellowship Program
* [ ] https://mdn-mm.moz.works/files/12984/web-font-example.png - Redirects to https://mdn-mm-demos.moz.works
* [ ] https://mdn-mm.moz.works/fr/docs/feeds/rss/l10n-updates/ - 200, RSS feed of out-of-date pages
* [ ] https://mdn-mm.moz.works/fr/docs/localization-tag/inprogress - 200, paginated list of documents
* [ ] https://mdn-mm.moz.works/humans.txt - 200, list of GitHub usernames
* [ ] https://mdn-mm.moz.works/media/kumascript-revision.txt - 200, git commit hash for kumascript
* [ ] https://mdn-mm.moz.works/media/revision.txt - 200, git commit hash for kuma
* [ ] https://mdn-mm.moz.works/presentations/microsummaries/index.html - 200, 2006 OSCON presentation
* [ ] https://mdn-mm.moz.works/robots.txt - 200, robots disallow list
* [ ] https://mdn-mm.moz.works/samples/webgl/sample3 - 200, Shows WebGL demo
* [ ] https://mdn-mm.moz.works/sitemap.xml - 200, list of sitemaps
* [ ] https://mdn-mm.moz.works/sitemaps/en-US/sitemap.xml - 200, list of en-US pages

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
