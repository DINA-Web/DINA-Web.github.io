---
layout: post
title: "Retrospection"
---

# In the back mirror

A workshop in Stockholm about a year ago, where teams from Canada, Estonia, Sweden, Denmark and representatives from the UK met up physically at the Swedish Museum for Natural History. Some materials from that workshop is on record here:

- <http://rpubs.com/mskyttner/dina-web>
- <http://rpubs.com/mskyttner/setf>
- <http://rpubs.com/mskyttner/tdwg-2014-dina-web>

# Summarizing

- One Rule / Rule One - **Web UIs** should get their data through Web services using **versioned and documented** Web APIs.

- Open Licenses for Code and Content.

# The "diff" since then

- Guidelines in place (for Web APIs, Web UI style, licensing) and tools for assessing Accessibility and Security 
- New logo and updated Poster presented at TDWG
- Modules progress - including the CLI tool Collections Batch Tool for data import / export, seqdb, media

# Looking forward

- User SSO module - suggesting to use keycloak.org to provide SSO and mgm of Users and their roles and permissions
- DINA-Specify module API getting ready to be released
- Vagrant and Docker files packaging the the DINA-Web system

# Web API strategy

> We plan to avoid a monolithic architecture by breaking the whole system into separate smaller modules that provide access to their data over web APIs and which links to related data in other modules using persistent identifiers. 

The idea is to use a Web API strategy - to open up and counter monolithic character of legacy systems. The Web API strategy is expected to enable and simplify improvements, maintenance and refactoring.

The first step is to make sure all client calls go over versioned and documented web APIs to server components, rather than "directly to db". 

After this step, it will be possible to "divide and conquer" in the areas where this is needed, ie it becomes possible to refactor and make changes behind the "API wall" without breaking clients.
