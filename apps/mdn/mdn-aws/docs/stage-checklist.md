This checklist uses these URLs:

* Base: https://stage.mdn.moz.works
* CDN: https://stage-cdn.mdn.moz.works
* Demo: https://stage-files.mdn.moz.works
* Interactive Examples: https://interactive-examples.mdn.moz.works

# Refreshing staging instance

The staging instance has separate services from the production instance. The
staging database is initialized from an anonymized production database
backup. This database persists between deployments, and is refreshed
infrequently.

*TODO:* Add instructions for refreshing the staging database.

# Manual Sanity Check

## Home page

Load https://developer.allizom.org/en-US

* [ ] Loads without errors
* [ ] Does not have banner "MDN is currently in read-only maintenance mode. Learn more."
* [ ] Has "Sign in" or "View Profile" at the top
* [ ] Has entries for the Hacks Blog

## Article page

Load https://developer.allizom.org/en-US/docs/Web/HTML

* [ ] Loads without errors
* [ ] No Maintenance Mode banner
* [ ] Has "Sign in" or "View Profile" at the top

# Automated Checks

With a Kuma environment,
[run the functional tests](https://kuma.readthedocs.io/en/latest/tests-ui.html),
using a command like:

```
py.test -m "not login" tests/functional tests/redirects --base-url https://developer.allizom.org --driver Chrome --driver-path /path/to/chromedriver
```

Some tests will fail the first time they are run against a server with cold
caches. Some tests are flakey, and will intermittantly fail. If a test passes
once in three tries, we consider it a success.

* [ ] Functional tests pass

These check basic site functionality without logging in. It duplicates the Manual Sanity Check.

```
py.test -m "not login" tests/functional tests/redirects --base-url https://developer.allizom.org --driver Chrome --driver-path /path/to/chromedriver
```

# Full Manual Tests

## Content tests

*Note: Many of these are candidates for headless testing*

These URLs should have similar results for anonymous or logged-in users:

* [ ] https://stage-files.mdn.moz.works/en-US/docs/Learn/CSS/Styling_text/Fundamentals$samples/Color - 200, sample as a stand-alone page
* [ ] https://stage-files.mdn.moz.works/files/12984/web-font-example.png - 200, PNG of some "Hipster ipsum" text
* [ ] https://developer.allizom.org/@api/deki/files/3613/=hut.jpg - 200, image of a hat
* [ ] https://developer.allizom.org/contribute.json - 200, project info
* [ ] https://developer.allizom.org/diagrams/workflow/workflow.svg - 200, SVG with images
* [ ] https://developer.allizom.org/en-US/dashboards/macros - 200, list of macros and page counts
* [ ] https://developer.allizom.org/en-US/dashboards/revisions - 200, list of recent changes
* [ ] https://developer.allizom.org/en-US/dashboards/spam - Redirects to Maintenance Mode page
* [ ] https://developer.allizom.org/en-US/docs/Learn/CSS/Styling_text/Fundamentals#Color - 200, with sample as iframe
* [ ] https://developer.allizom.org/en-US/docs/Learn/CSS/Styling_text/Fundamentals$toc - 200, HTML table of contents
* [ ] https://developer.allizom.org/en-US/docs/Web/HTML$children - 200, JSON list of child pages
* [ ] https://developer.allizom.org/en-US/docs/Web/HTML$compare?locale=en-US&to=1299417&from=1293895 - 200, compares revisions
* [ ] https://developer.allizom.org/en-US/docs/Web/HTML$history - 200, list of revisions
* [ ] https://developer.allizom.org/en-US/docs/Web/HTML$json - 200, JSON of page metadata
* [ ] https://developer.allizom.org/en-US/docs/Web/HTML$revision/1293895 - 200, historical revision
* [ ] https://developer.allizom.org/en-US/docs/Web/HTML$translate - Redirect to Maintenance Mode page
* [ ] https://developer.allizom.org/en-US/docs/all - 200, paginated list of docs
* [ ] https://developer.allizom.org/en-US/docs/ckeditor_config.js - 200, JavaScript
* [ ] https://developer.allizom.org/en-US/docs/feeds/atom/files/ - 200, Atom feed of changed files
* [ ] https://developer.allizom.org/en-US/docs/feeds/rss/all/ - 200, RSS feed of new pages
* [ ] https://developer.allizom.org/en-US/docs/feeds/rss/needs-review/ - 200, RSS feed of pages needing review
* [ ] https://developer.allizom.org/en-US/docs/feeds/rss/needs-review/technical - 200, RSS feed of pages needing technical review
* [ ] https://developer.allizom.org/en-US/docs/feeds/rss/revisions - 200, RSS feed of changes
* [ ] https://developer.allizom.org/en-US/docs/feeds/rss/tag/CSS - 200, RSS feed of pages with CSS tag
* [ ] https://developer.allizom.org/en-US/docs/needs-review/editorial - 200, paginated list of documents
* [ ] https://developer.allizom.org/en-US/docs/tag/ARIA - 200, list of documents
* [ ] https://developer.allizom.org/en-US/docs/tags - 200, paginated list of tags
* [ ] https://developer.allizom.org/en-US/docs/top-level - 200, paginated list of documents
* [ ] https://developer.allizom.org/en-US/docs/with-errors - 200, (empty?) paginated list of documents
* [ ] https://developer.allizom.org/en-US/docs/without-parent - 200, paginated list of documents
* [ ] https://developer.allizom.org/en-US/miel  - 500 Internal Server Error
* [ ] https://developer.allizom.org/en-US/profiles/sheppy - 200, Sheppy's profile
* [ ] https://developer.allizom.org/en-US/promote/ - 200, Promote MDN with 4 buttons
* [ ] https://developer.allizom.org/en-US/search - 200, Search results
* [ ] https://developer.allizom.org/fellowship/ - 200, 2015 MDN Fellowship Program
* [ ] https://developer.allizom.org/files/12984/web-font-example.png - Redirects to https://stage-files.mdn.moz.works
* [ ] https://developer.allizom.org/fr/docs/feeds/rss/l10n-updates/ - 200, RSS feed of out-of-date pages
* [ ] https://developer.allizom.org/fr/docs/localization-tag/inprogress - 200, paginated list of documents
* [ ] https://developer.allizom.org/humans.txt - 200, list of GitHub usernames
* [ ] https://developer.allizom.org/media/kumascript-revision.txt - 200, git commit hash for kumascript
* [ ] https://developer.allizom.org/media/revision.txt - 200, git commit hash for kuma
* [ ] https://developer.allizom.org/presentations/microsummaries/index.html - 200, 2006 OSCON presentation
* [ ] https://developer.allizom.org/robots.txt - 200, robots disallow list
* [ ] https://developer.allizom.org/samples/webgl/sample3 - 200, Shows WebGL demo
* [ ] https://developer.allizom.org/sitemap.xml - 200, list of sitemaps
* [ ] https://developer.allizom.org/sitemaps/en-US/sitemap.xml - 200, list of en-US pages

## Anonymous tests

Test these URLs as an anonymous user:

* [ ] https://developer.allizom.org/admin/users/user/1/ - 302 redirect to the Admin login page, asking for a username and password.
* [ ] https://developer.allizom.org/en-US/docs/Web/HTML$edit - 302 redirect to user sign-in page, asking to Sign In with GitHub

## Regular Account Tests

Some things to try with a regular account, to exercise write functionality:

* [ ] Create a new MDN user account (may require deleting your ``SocialAccount``)
* [ ] Send a account recovery link for an existing MDN user account
* [ ] Update the account profile
* [ ] Add and verify a new email for a profile
* [ ] Create a new page, such as https://developer.allizom.org/en-US/docs/User:Test
* [ ] Create a translation of the the page
* [ ] Subscribe to a page, and change it with a different account
* [ ] Update the original page with a KumaScript macro, such as ``{{cssxref("background")}}``.
* [ ] Update the translation of a changed English page
* [ ] Upload an image to the page
* [ ] Add the image to the page content
* [ ] Log out

## Admin Tests

* [ ] Move a page
* [ ] Delete a page
* [ ] View https://developer.allizom.org/admin/users/user/1/

