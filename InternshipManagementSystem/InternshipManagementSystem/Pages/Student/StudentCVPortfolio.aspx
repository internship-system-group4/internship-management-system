
<%@ Page Title="Student CV & Portfolio"
    Language="C#"
    MasterPageFile="~/Layout/Student.master"
    AutoEventWireup="true"
    CodeBehind="StudentCVPortfolio.aspx.cs"
    Inherits="InternshipManagementSystem.Pages.StudentArea.StudentCVPortfolio" %>

<asp:Content ID="Head"
    ContentPlaceHolderID="head"
    runat="server">

<style>
.cv-page {
    max-width: 1080px;
    margin: 0 auto;
    color: var(--th-fg-20314b,#20314b);
}

.cv-heading {
    margin-bottom: 24px;
}

.cv-heading h2 {
    font-size: 1.7rem;
    font-weight: 750;
    margin: 0 0 8px;
}

.cv-muted {
    color: var(--th-fg-64748b,#64748b);
    line-height: 1.7;
}

.cv-panel {
    background: var(--ui-surface,#fff);
    border: 1px solid var(--th-line-e0e6ee,#e0e6ee);
    border-radius: 15px;
    padding: 25px;
    margin-bottom: 20px;
}

.cv-panel h3 {
    font-size: 1.15rem;
    font-weight: 750;
    margin-bottom: 8px;
}

.cv-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
}

.cv-field {
    margin-top: 20px;
}

.cv-field label {
    display: block;
    font-weight: 650;
    margin-bottom: 8px;
}

.cv-input {
    width: 100%;
    border: 1px solid var(--th-line-cbd5e1,#cbd5e1);
    border-radius: 9px;
    padding: 12px;
    background: var(--ui-surface,#ffffff);
    color: var(--th-fg-20314b,#20314b);
}

.cv-help {
    display: block;
    color: var(--th-fg-718096,#718096);
    font-size: .85rem;
    margin-top: 7px;
}

.cv-upload {
    border: 2px dashed var(--th-line-cbd8e7,#cbd8e7);
    border-radius: 12px;
    background: var(--th-bg-f8fbff,#f8fbff);
    padding: 20px;
}

.cv-btn {
    display: inline-block;
    padding: 12px 20px;
    border: 0;
    border-radius: 9px;
    background: var(--th-bg-285aa0,#285aa0);
    color: #fff;
    font-weight: 700;
    cursor: pointer;
    text-decoration: none;
}

.cv-btn:hover {
    background: var(--th-bg-1c477e,#1c477e);
    color: #fff;
}

.cv-btn-outline {
    background: var(--th-bg-edf3fb,#edf3fb);
    color: var(--th-fg-285aa0,#285aa0);
}

.cv-btn-outline:hover {
    background: var(--th-bg-dfeafa,#dfeafa);
    color: var(--th-fg-285aa0,#285aa0);
}

.cv-btn-danger {
    background: var(--th-bg-fff1f1,#fff1f1);
    color: var(--th-fg-a02d39,#a02d39);
}

.cv-btn-danger:hover {
    background: var(--th-bg-ffe1e1,#ffe1e1);
    color: var(--th-fg-a02d39,#a02d39);
}

.cv-actions {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    margin-top: 20px;
}

.cv-saved {
    border: 1px solid var(--th-line-e3eaf2,#e3eaf2);
    border-radius: 11px;
    padding: 17px;
    margin-top: 15px;
    overflow-wrap: anywhere;
}

.cv-saved strong {
    display: block;
    margin-bottom: 8px;
}

.cv-saved a {
    color: var(--th-fg-285aa0,#285aa0);
}

.cv-empty {
    color: var(--th-fg-7b8797,#7b8797);
    font-size: .9rem;
}

.cv-notice {
    padding: 14px 17px;
    margin-bottom: 20px;
    border-radius: 10px;
    background: var(--th-bg-e7f5ed,#e7f5ed);
    color: var(--th-fg-17603a,#17603a);
}

.cv-notice.error {
    background: var(--th-bg-fff0ed,#fff0ed);
    color: var(--th-fg-a13d2d,#a13d2d);
}

.cv-footer {
    display: flex;
    justify-content: flex-end;
    gap: 12px;
    margin-top: 20px;
}

@media (max-width: 780px) {
    .cv-grid {
        grid-template-columns: 1fr;
    }

    .cv-panel {
        padding: 18px;
    }

    .cv-footer {
        justify-content: stretch;
    }

    .cv-footer .cv-btn {
        flex: 1;
    }
}
</style>

</asp:Content>

<asp:Content ID="Body"
    ContentPlaceHolderID="MainContent"
    runat="server">

<div class="cv-page">
    
<div style="margin-bottom:22px;">
    <a href="<%: ResolveUrl("~/Pages/Student/Profile.aspx") %>"
       style="color:var(--th-fg-28547d,#28547d);
              text-decoration:none;
              font-size:13px;
              font-weight:700;">
        <%: L.T("Student.StudentCVPortfolio.BackToMyProfile") %>
    </a>
</div>

    
<div class="cv-heading">
    <h2><%: L.T("Student.StudentCVPortfolio.MyCVPortfolio") %></h2>

    <p class="cv-muted">
        <%: L.T("Student.StudentCVPortfolio.BuildYourProfessionalPresenceByManaging") %>
    </p>
</div>


    <% if (!string.IsNullOrEmpty(Notice)) { %>

        <div class='cv-notice <%= NoticeIsError ? "error" : "" %>'
             role="alert">
            <%: Notice %>
        </div>

    <% } %>

    <!-- CV and Portfolio Links -->

    <div class="cv-panel">

        <h3><%: L.T("Student.StudentCVPortfolio.CVPortfolioLinks") %></h3>

        <p class="cv-muted">
            <%: L.T("Student.StudentCVPortfolio.AddLinksToYourOnlineCV") %>
        </p>

        <div class="cv-grid">

            <div class="cv-field">

                <label for="cvUrl">
                    <%: L.T("Student.StudentCVPortfolio.CVLink") %>
                </label>

                <input type="url"
                       id="cvUrl"
                       name="cvUrl"
                       class="cv-input"
                       maxlength="500"
                       placeholder="https://example.com/my-cv"
                       value="<%: Saved.CvUrl %>" />

                <span class="cv-help">
                    <%: L.T("Student.StudentCVPortfolio.AddALinkToYourOnline") %>
                </span>

            </div>

            <div class="cv-field">

                <label for="portfolioUrl">
                    <%: L.T("Student.StudentCVPortfolio.PortfolioLink") %>
                </label>

                <input type="url"
                       id="portfolioUrl"
                       name="portfolioUrl"
                       class="cv-input"
                       maxlength="500"
                       placeholder="https://github.com/username"
                       value="<%: Saved.PortfolioUrl %>" />

                <span class="cv-help">
                    <%: L.T("Student.StudentCVPortfolio.GitHubBehanceOrAPersonalWebsite") %>
                </span>

            </div>

        </div>

    </div>

    <!-- File Upload -->

    <div class="cv-grid">

        <div class="cv-panel">

            <h3><%: L.T("Student.StudentCVPortfolio.UploadCV") %></h3>

            <p class="cv-muted">
                <%: L.T("Student.StudentCVPortfolio.UploadYourLatestCVAsA") %>
            </p>

            <div class="cv-field cv-upload">

                <label for="cvFile">
                    <%: L.T("Student.StudentCVPortfolio.ChooseCVFile") %>
                </label>

                <input type="file"
                       id="cvFile"
                       name="cvFile"
                       class="cv-input"
                       accept=".pdf,application/pdf" />

                <span class="cv-help">
                    <%: L.T("Student.StudentCVPortfolio.PDFOnlyMaximumFileSize5") %>
                </span>

            </div>

        </div>

        <div class="cv-panel">

            <h3><%: L.T("Student.StudentCVPortfolio.UploadPortfolio") %></h3>

            <p class="cv-muted">
                <%: L.T("Student.StudentCVPortfolio.UploadAPDFContainingYourProjects") %>
            </p>

            <div class="cv-field cv-upload">

                <label for="portfolioFile">
                    <%: L.T("Student.StudentCVPortfolio.ChoosePortfolioFile") %>
                </label>

                <input type="file"
                       id="portfolioFile"
                       name="portfolioFile"
                       class="cv-input"
                       accept=".pdf,application/pdf" />

                <span class="cv-help">
                    <%: L.T("Student.StudentCVPortfolio.PDFOnlyMaximumFileSize5") %>
                </span>

            </div>

        </div>

    </div>

    <!-- Save -->

    <div class="cv-panel">

        <h3><%: L.T("Student.StudentCVPortfolio.SaveYourInformation") %></h3>

        <p class="cv-muted">
            <%: L.T("Student.StudentCVPortfolio.SaveYourLinksAndSelectedFiles") %>
        </p>

        <div class="cv-footer">

            <button type="submit"
                    name="cvAction"
                    value="save"
                    class="cv-btn" data-ui-action="save" data-ui-validation="none" data-loading-label="Saving…">
                <%: L.T("Student.StudentCVPortfolio.SaveCVPortfolio") %>
            </button>

        </div>

    </div>

    <!-- Saved Content -->

    <div class="cv-panel">

        <h3><%: L.T("Student.StudentCVPortfolio.MySavedCVPortfolio") %></h3>

        <p class="cv-muted">
            <%: L.T("Student.StudentCVPortfolio.ViewYourPreviouslySavedLinksAnd") %>
        </p>

        <div class="cv-grid">

            <div>

                <div class="cv-saved">

                    <strong><%: L.T("Student.StudentCVPortfolio.CVLink") %></strong>

                    <% if (!string.IsNullOrWhiteSpace(Saved.CvUrl)) { %>

                        <a href="<%: Saved.CvUrl %>"
                           target="_blank"
                           rel="noopener noreferrer">
                            <%: L.T("Student.StudentCVPortfolio.ViewCVLink") %>
                        </a>

                    <% } else { %>

                        <span class="cv-empty">
                            <%: L.T("Student.StudentCVPortfolio.NoCVLinkAddedYet") %>
                        </span>

                    <% } %>

                </div>

                <div class="cv-saved">

                    <strong><%: L.T("Student.StudentCVPortfolio.UploadedCV") %></strong>

                    <% if (!string.IsNullOrWhiteSpace(
                        Saved.CvStorageName)) { %>

                        <div>
                            <%: Saved.CvFileName %>
                        </div>

                        <div class="cv-actions">

                            <a class="cv-btn cv-btn-outline"
                               href="StudentCVPortfolio.aspx?download=cv">
                                <%: L.T("Student.StudentCVPortfolio.DownloadCV") %>
                            </a>

                            <button type="submit"
                                    name="cvAction"
                                    value="removeCv"
                                    class="cv-btn cv-btn-danger"
                                    onclick="return confirm('Remove your CV file?');" data-ui-action="delete" data-ui-validation="none" data-loading-label="Deleting…">
                                <%: L.T("Student.StudentCVPortfolio.Remove") %>
                            </button>

                        </div>

                    <% } else { %>

                        <span class="cv-empty">
                            <%: L.T("Student.StudentCVPortfolio.NoCVFileUploadedYet") %>
                        </span>

                    <% } %>

                </div>

            </div>

            <div>

                <div class="cv-saved">

                    <strong><%: L.T("Student.StudentCVPortfolio.PortfolioLink") %></strong>

                    <% if (!string.IsNullOrWhiteSpace(
                        Saved.PortfolioUrl)) { %>

                        <a href="<%: Saved.PortfolioUrl %>"
                           target="_blank"
                           rel="noopener noreferrer">
                            <%: L.T("Student.StudentCVPortfolio.ViewPortfolio") %>
                        </a>

                    <% } else { %>

                        <span class="cv-empty">
                            <%: L.T("Student.StudentCVPortfolio.NoPortfolioLinkAddedYet") %>
                        </span>

                    <% } %>

                </div>

                <div class="cv-saved">

                    <strong><%: L.T("Student.StudentCVPortfolio.UploadedPortfolio") %></strong>

                    <% if (!string.IsNullOrWhiteSpace(
                        Saved.PortfolioStorageName)) { %>

                        <div>
                            <%: Saved.PortfolioFileName %>
                        </div>

                        <div class="cv-actions">

                            <a class="cv-btn cv-btn-outline"
                               href="StudentCVPortfolio.aspx?download=portfolio">
                                <%: L.T("Student.StudentCVPortfolio.DownloadPortfolio") %>
                            </a>

                            <button type="submit"
                                    name="cvAction"
                                    value="removePortfolio"
                                    class="cv-btn cv-btn-danger"
                                    onclick="return confirm('Remove your portfolio file?');" data-ui-action="delete" data-ui-validation="none" data-loading-label="Deleting…">
                                <%: L.T("Student.StudentCVPortfolio.Remove") %>
                            </button>

                        </div>

                    <% } else { %>

                        <span class="cv-empty">
                            <%: L.T("Student.StudentCVPortfolio.NoPortfolioFileUploadedYet") %>
                        </span>

                    <% } %>

                </div>

            </div>

        </div>

    </div>

</div>


<script type="text/javascript">
    (function () {
        var form = document.querySelector("form");

        if (form) {
            form.setAttribute("enctype", "multipart/form-data");
            form.setAttribute("encoding", "multipart/form-data");
        }
    })();
</script>


</asp:Content>
