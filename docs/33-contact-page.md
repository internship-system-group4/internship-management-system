# Contact Us page

The Contact Us page is `Pages/Public/Contact.aspx`, with its code-behind. Its files are:
- `Assets/css/contact.css` and `Assets/js/contact.js`;
- `Assets/js/public-forms.js`, the shared script that handles validation, the busy state and the duplicate-send guard.

## Storage contract (unchanged)

Messages are saved with a POST to Firebase `/ContactMessages.json`, which generates the key. The fields are:

| Field | Value |
| --- | --- |
| `Name` | as entered |
| `Email` | as entered |
| `Subject` | as entered |
| `Message` | as entered |
| `Status` | `"New"` |
| `SubmittedAt` | Unix time in milliseconds |

`Pages/Coordinator/ContactMessages.aspx` reads them, and its compatibility was verified against the fixture. Server control IDs are unchanged: `txtName`, `txtEmail`, `txtSubject`, `txtMessage`, `Website`, `btnSend` and `lblMessage`.

## Behaviour

- **Validation:** the browser checks a field once the visitor has typed in it and moves on, and checks every field on Send. The server checks every field again. Errors appear beside each field, with `aria-invalid` and `aria-describedby`, an icon and words. The server also shows a summary that receives focus.
- **Limits:**

  | Field | Limit |
  | --- | --- |
  | Name | 2–100 characters |
  | Email | 254 characters, `name@domain.tld` format |
  | Subject | 5–150 characters |
  | Message | 20–4,000 characters |

  These are the limits the form already displayed. The server previously accepted subject ≥ 3 and message 10–5,000; it now matches the form.
- **"Form readiness":** four segments, one per field, showing local validity only. It is not a live region, and it makes no claim that anything was sent.
- **Envelope:** decorative (`aria-hidden`, no pointer events). The letter rises as the fields become valid.
- **Sending:** a spinner and "Sending…", `aria-busy`, a status message, and a steady button size. The existing guard blocks a second send.
- **Success:** shown only after Firebase confirms the save. The page then uses post/redirect/get to `Contact.aspx?sent=1#contact-form`, and a one-time session flag decides whether "Message sent" appears. A refresh cannot resend. "Send another message" is a real page load.
- **Failure:** the visitor keeps everything they typed and sees "Your message could not be sent right now…". No technical details are shown; the reason goes to the trace log only.

## Not changed

The honeypot field `Website` exists but the server does not check it. It was like this before this work and is left as it is.

## Verification (fixture only)

`tests/contact-page.browser.js` passes 53/53 against the Firebase fixture in `postman/mocks/firebase`. That fixture now handles POST, has a coordinator user, and has `__slow-writes` and `__fail-writes` switches. Nothing was verified against live Firebase.
