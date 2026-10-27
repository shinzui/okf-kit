let Schema =
      https://raw.githubusercontent.com/shinzui/mori-schema/3522f4a51181d73c9c90fc27a7c0838bd29ae95f/package.dhall
        sha256:dcb19e2312e790bad14e622cc98a1281cd2298c5b564a2f0d0534d3c718d8803

in  Schema.Project::{
    , project = Schema.ProjectIdentity::{
      , name = "okf-kit"
      , namespace = "shinzui"
      , stableId = Some "project_01m5zftnrsebg9e1pmpe1ds2fc"
      , type = Schema.PackageType.Other "Kit"
      , language = Schema.Language.Other "Markdown"
      , lifecycle = Schema.Lifecycle.Active
      , description = Some
          "Reusable AI-agent skills and subagents for okf, installed via okf kit"
      , domains = [ "Data", "Developer Tooling" ]
      , owners = [ "shinzui" ]
      }
    , repos = [ Schema.Repo::{ name = "okf-kit", github = Some "shinzui/okf-kit" } ]
    , dependencies = [ "shinzui/okf" ]
    , dependencyRefs =
      [ Schema.MoriRef::{ namespace = "shinzui", name = "okf" } ]
    , skills =
      [ Schema.Skill::{
        , name = "author-okf-concept"
        , description =
            "Author a new OKF v0.2 concept document with valid frontmatter, provenance, path, links, and a validation check"
        , path = Some "skills/author-okf-concept"
        }
      , Schema.Skill::{
        , name = "author-okf-computation"
        , description =
            "Author an OKF v0.2 Attested Computation concept with its five contract keys and the exactly-one-computation rule"
        , path = Some "skills/author-okf-computation"
        }
      , Schema.Skill::{
        , name = "author-okf-capabilities"
        , description =
            "Author a profile-governed capability catalog at docs/capabilities describing what a project provides today, shaped by the project's type"
        , path = Some "skills/author-okf-capabilities"
        }
      , Schema.Skill::{
        , name = "migrate-okf-bundle-to-v0-2"
        , description =
            "Migrate an OKF v0.1 bundle to v0.2: timestamp to generated, the new families, and the okf_version declaration"
        , path = Some "skills/migrate-okf-bundle-to-v0-2"
        }
      , Schema.Skill::{
        , name = "triage-okf-validation"
        , description =
            "Triage okf validate errors, strict diagnostics, profile deviations, and log advisories, then propose minimal fixes"
        , path = Some "skills/triage-okf-validation"
        }
      ]
    , subagents =
      [ Schema.Subagent::{
        , name = "okf-guide"
        , description =
            "An assistant persona for authoring, validating, and inspecting OKF v0.2 bundles"
        , provider = Some "claude-code"
        }
      ]
    }
