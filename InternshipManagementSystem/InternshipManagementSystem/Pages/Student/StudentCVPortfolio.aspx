
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
    color: #20314b;
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
    color: #64748b;
    line-height: 1.7;
}

.cv-panel {
    background: #fff;
    border: 1px solid #e0e6ee;
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
    border: 1px solid #cbd5e1;
    border-radius: 9px;
    padding: 12px;
    background: white;
    color: #20314b;
}

.cv-help {
    display: block;
    color: #718096;
    font-size: .85rem;
    margin-top: 7px;
}

.cv-upload {
    border: 2px dashed #cbd8e7;
    border-radius: 12px;
    background: #f8fbff;
    padding: 20px;
}

.cv-btn {
    display: inline-block;
    padding: 12px 20px;
    border: 0;
    border-radius: 9px;
    background: #285aa0;
    color: #fff;
    font-weight: 700;
    cursor: pointer;
    text-decoration: none;
}

.cv-btn:hover {
    background: #1c477e;
    color: #fff;
}

.cv-btn-outline {
    background: #edf3fb;
    color: #285aa0;
}

.cv-btn-outline:hover {
    background: #dfeafa;
    color: #285aa0;
}

.cv-btn-danger {
    background: #fff1f1;
    color: #a02d39;
}

.cv-btn-danger:hover {
    background: #ffe1e1;
    color: #a02d39;
}

.cv-actions {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    margin-top: 20px;
}

.cv-saved {
    border: 1px solid #e3eaf2;
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
    color: #285aa0;
}

.cv-empty {
    color: #7b8797;
    font-size: .9rem;
}

.cv-notice {
    padding: 14px 17px;
    margin-bottom: 20px;
    border-radius: 10px;
    background: #e7f5ed;
    color: #17603a;
}

.cv-notice.error {
    background: #fff0ed;
    color: #a13d2d;
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

    <div class="cv-heading">
        <h2>Student CV &amp; Portfolio</h2>

        <p class="cv-muted">
            Manage your CV and portfolio to showcase
            your skills, projects, and experience.
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

        <h3>CV &amp; Portfolio Links</h3>

        <p class="cv-muted">
            Add links to your online CV and portfolio.
            You can update them whenever needed.
        </p>

        <div class="cv-grid">

            <div class="cv-field">

                <label for="cvUrl">
                    CV Link
                </label>

                <input type="url"
                       id="cvUrl"
                       name="cvUrl"
                       class="cv-input"
                       maxlength="500"
                       placeholder="https://example.com/my-cv"
                       value="<%: Saved.CvUrl %>" />

                <span class="cv-help">
                    Add a link to your online CV.
                </span>

            </div>

            <div class="cv-field">

                <label for="portfolioUrl">
                    Portfolio Link
                </label>

                <input type="url"
                       id="portfolioUrl"
                       name="portfolioUrl"
                       class="cv-input"
                       maxlength="500"
                       placeholder="https://github.com/username"
                       value="<%: Saved.PortfolioUrl %>" />

                <span class="cv-help">
                    GitHub, Behance, or a personal website.
                </span>

            </div>

        </div>

    </div>

    <!-- File Upload -->

    <div class="cv-grid">

        <div class="cv-panel">

            <h3>Upload CV</h3>

            <p class="cv-muted">
                Upload your latest CV as a PDF document.
            </p>

            <div class="cv-field cv-upload">

                <label for="cvFile">
                    Choose CV File
                </label>

                <input type="file"
                       id="cvFile"
                       name="cvFile"
                       class="cv-input"
                       accept=".pdf,application/pdf" />

                <span class="cv-help">
                    PDF only. Maximum file size: 5 MB.
                </span>

            </div>

        </div>

        <div class="cv-panel">

            <h3>Upload Portfolio</h3>

            <p class="cv-muted">
                Upload a PDF containing your projects,
                skills, and previous work.
            </p>

            <div class="cv-field cv-upload">

                <label for="portfolioFile">
                    Choose Portfolio File
                </label>

                <input type="file"
                       id="portfolioFile"
                       name="portfolioFile"
                       class="cv-input"
                       accept=".pdf,application/pdf" />

                <span class="cv-help">
                    PDF only. Maximum file size: 5 MB.
                </span>

            </div>

        </div>

    </div>

    <!-- Save -->

    <div class="cv-panel">

        <h3>Save Your Information</h3>

        <p class="cv-muted">
            Save your links and selected files.
            You can return to this page later
            to view or update them.
        </p>

        <div class="cv-footer">

            <button type="submit"
                    name="cvAction"
                    value="save"
                    class="cv-btn">
                Save CV &amp; Portfolio
            </button>

        </div>

    </div>

    <!-- Saved Content -->

    <div class="cv-panel">

        <h3>My Saved CV &amp; Portfolio</h3>

        <p class="cv-muted">
            View your previously saved links and documents.
        </p>

        <div class="cv-grid">

            <div>

                <div class="cv-saved">

                    <strong>CV Link</strong>

                    <% if (!string.IsNullOrWhiteSpace(Saved.CvUrl)) { %>

                        <a href="<%: Saved.CvUrl %>"
                           target="_blank"
                           rel="noopener noreferrer">
                            View CV Link
                        </a>

                    <% } else { %>

                        <span class="cv-empty">
                            No CV link added yet.
                        </span>

                    <% } %>

                </div>

                <div class="cv-saved">

                    <strong>Uploaded CV</strong>

                    <% if (!string.IsNullOrWhiteSpace(
                        Saved.CvStorageName)) { %>

                        <div>
                            <%: Saved.CvFileName %>
                        </div>

                        <div class="cv-actions">

                            <a class="cv-btn cv-btn-outline"
                               href="StudentCVPortfolio.aspx?download=cv">
                                Download CV
                            </a>

                            <button type="submit"
                                    name="cvAction"
                                    value="removeCv"
                                    class="cv-btn cv-btn-danger"
                                    onclick="return confirm('Remove your CV file?');">
                                Remove
                            </button>

                        </div>

                    <% } else { %>

                        <span class="cv-empty">
                            No CV file uploaded yet.
                        </span>

                    <% } %>

                </div>

            </div>

            <div>

                <div class="cv-saved">

                    <strong>Portfolio Link</strong>

                    <% if (!string.IsNullOrWhiteSpace(
                        Saved.PortfolioUrl)) { %>

                        <a href="<%: Saved.PortfolioUrl %>"
                           target="_blank"
                           rel="noopener noreferrer">
                            View Portfolio
                        </a>

                    <% } else { %>

                        <span class="cv-empty">
                            No portfolio link added yet.
                        </span>

                    <% } %>

                </div>

                <div class="cv-saved">

                    <strong>Uploaded Portfolio</strong>

                    <% if (!string.IsNullOrWhiteSpace(
                        Saved.PortfolioStorageName)) { %>

                        <div>
                            <%: Saved.PortfolioFileName %>
                        </div>

                        <div class="cv-actions">

                            <a class="cv-btn cv-btn-outline"
                               href="StudentCVPortfolio.aspx?download=portfolio">
                                Download Portfolio
                            </a>

                            <button type="submit"
                                    name="cvAction"
                                    value="removePortfolio"
                                    class="cv-btn cv-btn-danger"
                                    onclick="return confirm('Remove your portfolio file?');">
                                Remove
                            </button>

                        </div>

                    <% } else { %>

                        <span class="cv-empty">
                            No portfolio file uploaded yet.
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
