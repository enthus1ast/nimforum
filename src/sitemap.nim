import simpleSitemap, strformat, times, os

when NimMajor >= 1 and NimMinor >= 9:
  import db_connector/db_sqlite
else:
  import std/db_sqlite

type
  SitemapGenerator* = object
    dbconn: Dbconn

proc newSitemapGenerator*(dbconn: DbConn): SitemapGenerator =
  result = SitemapGenerator()
  result.dbconn = dbconn

proc generate*(sg: SitemapGenerator) =
  var urlDates: seq[UrlDate] = @[]
  let baseUrl = "https://forum.nim-lang.org"
  for row in sg.dbconn.rows(sql"select id, name, modified from thread"):
    urlDates.add (fmt"{baseUrl}/t/{row[0]}/{row[1]}", row[2].parse("yyyy-MM-dd H':'m':'s"))
  let pages = generateSitemaps(
    urlDates,
    urlsOnRecent = 30,
    maxUrlsPerSitemap = 50_000,
    base = "https://forum.nim-lang.org/"
  )
  write(pages, folder = getAppDir() / "public")