# SI-Etudiants Investigation: Annuaire & Relations

## Objective

Building the relations between students for use in palantint.

## Progress Summary

Investigating group relations by navigating `Dossier.aspx` and `OngletStandard.aspx` pages for `idObjet` in the range 1924 to 14886.

### 1. Group Naming Conventions & Identification
Through manual exploration and browser-based investigation, the following naming patterns for student groups (Classes) have been identified:
- **TSP - FISE**: `CL_FI_EI` (Formation Initiale Sous Statut Étudiant)
- **TSP - FISA**: `CL_FIPA-` (Formation Initiale par Apprentissage)
- **IMT-BS - Bachelor**: `CL_FE-Bachelorx`
- **IMT-BS - EM**: `CL_FE-EM`
- **Various Groups**: `Gp-`
- **General Type**: `idTypeObjet = 28` corresponds to "Organisme" / "Classe".

### 2. Hierarchical Structure & Inverse Relations
- **Group -> Student (Parent/Child)**:
    - **Parent Relation**: "A pour Entité mère" (e.g., `CL_FE-EM3` belongs to `Classes Formation Initiale`).
    - **Child Relation**: "Est Classe de" (links the group to individual `idObjet` students).
- **Student -> Group (Membership)**:
    - When viewing a student (**`idTypeObjet = 1`**), the relations tab (`IdOnglet=7`) shows their memberships.
    - **Relation Type**: "Est dans la Classe" (for main promotion classes like `CL_FI_EI1`).
    - **Relation Type**: "Est dans le Groupe" (for specific groups like `Gp-EI1-G`, `GP-LSH-ENG`, etc.).

### 3. The `GObjet` Mechanism & Session Flow
Accessing specific data tabs in the Annuaire module is a stateful process requiring proper session initialization:
1.  **Initialize the Session**: You must hit the Annuaire launcher URL with a proper `Referer` from the `Noyau` (Core) module. Failure to do so often results in a 500 Internal Server Error or "Error Code 5" (Access Denied).
    - `GET https://si-etudiants.imtbs-tsp.eu/OpDotNet/Eplug/Annuaire/Annuaire.asp?IdApplication=5`
    - `Referer: https://si-etudiants.imtbs-tsp.eu/OpDotNet/Noyau/Default.aspx`
2.  **Fetch the Dossier**: Hit the container page for the specific object.
    - `GET /OpDotNet/Eplug/Annuaire/Navigation/Dossier/Dossier.aspx?idObjet={id}&idTypeObjet=28&IdOnglet=7`
3.  **Extract GObjet**: The server generates a unique `GObjet` GUID for the view. This can be found in the `<iframe>` `src` or the `form action` of the page.
    - Regex: `GObjet=([0-9a-fA-F-]+)`
4.  **Fetch Relations Tab**: Use the retrieved `GObjet` to fetch the actual grid content.
    - `GET /OpDotNet/Eplug/Annuaire/Navigation/Dossier/Onglets/OngletStandard.aspx?GObjet={guid}&IdObjet={id}&IdTypeObjet={type}&IdOnglet=7`

### 4. Sample Probe Requests
To investigate an object's relations programmatically:
```bash
# 1. Warm up session
curl -H "Referer: .../Default.aspx" "https://.../Annuaire.asp?IdApplication=5"

# 2. Get GObjet from Dossier
curl -H "Referer: .../Annuaire.asp?IdApplication=5" \
     "https://.../Dossier.aspx?idObjet=1928&idTypeObjet=28" | grep -oP "GObjet=[0-9a-fA-F-]+"

# 3. Fetch Relations Grid
curl "https://.../OngletStandard.aspx?GObjet={GUID}&IdObjet=1928&IdTypeObjet=28&IdOnglet=7"
```
### 5. Discovery: Direct ID Probing (Not Search)

> **⚠️ Critical Finding:** The Annuaire search engine (`Recherche.aspx`) **only queries people** (`idTypeObjet=25`), not organisms/groups (`idTypeObjet=28`). The `?idTypeObjet=28` URL parameter is silently ignored by the server. All search queries (e.g., `CL_FI`, `GP-`, `*`) return **person records**, not groups.

Because of this, `groupes.py` uses **direct ID probing** across known ranges rather than search-based discovery.

#### Architecture: Probe & Filter
1.  **Initialize Context**: 6-phase ASP.NET handshake to establish Annuaire session.
2.  **Verify Access**: Probe known ID `1928` (`CL_FE-EM3`) to confirm session validity.
3.  **Probe Ranges**: For each candidate `idObjet` in predefined ranges:
    - `GET Dossier.aspx?idObjet={id}&idTypeObjet=28&IdOnglet=7` → extract `GObjet` GUID from `<iframe id="frm0">` src.
    - `GET OngletStandard.aspx?GObjet={guid}&...` → fetch relations DataGrid.
    - `POST OngletStandard.aspx` with `NbLignes=500` → reload to get all member rows.
4.  **Filter**: Only groups whose name matches `GROUP_PATTERNS` (e.g., `CL_FI`, `CL_FE`, `Gp-`) are kept.
5.  **Extract Members**: Parse DataGrid rows with relations like "Est Classe de", "Est dans le Groupe".

#### Known Probe Ranges
| Range       | Content                                     |
|-------------|---------------------------------------------|
| 1920–2200   | Core classes (`CL_FE-EM*`, `CL_FI-EI*`)    |
| 7600–8000   | Language/Humanities groups (`Gp-LSH-*`)     |
| 9000–9500   | Various elective groups                     |
| 10000–10500 | Course groups                               |
| 11000–11500 | Additional groups                           |

### 6. Script Maintenance
- **`GROUP_PATTERNS`**: Add new regex patterns to capture additional group naming conventions.
- **`PROBE_RANGES`**: Expand the ID ranges if new groups are discovered outside existing bounds.
