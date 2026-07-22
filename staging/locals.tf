locals {
  # Inline-code hashes for the Docusaurus website CSP (staging.piksel.big.go.id).
  # Regenerate from a production build when main-website changes its inline scripts or styles.
  website_csp_hashes = {
    # inline <script> blocks: theme-init (all pages) + base-URL banners (id/en home)
    script = [
      "sha256-cwuLNOro1rKKV3tYMKUxJTCXwdmGh2ndC/hn1LmXyjQ=",
      "sha256-0MUyFJhUwQbJbxdRddDw1q7CMNQ//leUWFbuI6XcmZo=",
      "sha256-l75NlFdSAwyAIr8HS79hfv4NDLEpCvkAqGGjpbeKw2M=",
    ]
    # inline style="" values: Prism theme colors, announcement bar, component palette
    style = [
      "sha256-mMk19IBj9VYyfXJkcfH4OsT3XlIM4Xyk7QkXk3q7OOA=",
      "sha256-wfFRBRN9VtnoKyjFp7nESoyL5GicNVcIrkvfmAPxv1s=",
      "sha256-1VpqF7JvfWhhKFUN/Wgu7QDcbPzydQkyrlTIeZlgKuA=",
      "sha256-oGgninVhefP1RL1F+kvhagCxY4G3ZZjBfXXp6bCjrEM=",
      "sha256-pXWn7Y697QsrJXquMTeNXeI/S2L1yWROlcGv9xY1GDA=",
      "sha256-TS84dZatrtdrL4Urdf9hRCy+KyN1mPKRgZ7aneRogWU=",
      "sha256-wVdTdG36cUXYw/mx9TBAbE5C5851vdt2ZDXM9Wdfips=",
      "sha256-Ls5ZNw60cr+qFp+vOMa3XqxqXIeaEJRIW5LVBMg8WpM=",
      "sha256-xMg5igwNvbA3rDpJ8MKzJiCrIDz+/ITK8enKfcHA+ZY=",
      "sha256-bxsltV6TfeWDqkKzBdLk9MHtWuel0dEljCHu/5+q/QI=",
      "sha256-qOUXaVhMwjZmqqi5+W6pNR5QK3wCiUgqOEkYBZAaaG4=",
      "sha256-Fs5uL8gxgNPhzxsyazlrOrPlBr99YkLVQPAjy0lCWKo=",
      "sha256-IcqGb0TAbH6mKQhvd8hBx2FAalfysv4UbOSlrgEnNqs=",
      "sha256-AIsMoEZ2AFYSNPqPHAPTfeQBkBx0uwe/S138h7oBgqk=",
      "sha256-sDIENtrZwmox3spLJOzzFKFmi3ELZ0v+EkEB+J8SMrA=",
      "sha256-mG3x7kPh9Tg2tpVcQvu9qSUpO0QuLZP1E4wDzpTKrMc=",
      "sha256-eslHeDkvJNiffFsT711OoAWNr5i7S9CBs7nlwyVzHxo=",
      "sha256-biLFinpqYMtWHmXfkA1BPeCY0/fNt46SAZ+BBk5YUog=",
      "sha256-jKE6QZqne5OsrfemNvuLSNoud++NsCOiSlGuIsQns5o=",
      "sha256-+YWRMZ88jMyO7jVlBA52tZADiPobPIUA8LAWee68Fvs=",
      "sha256-FI2V0tcYCmlxWCS2yvjBtDyaaZj1TbWYUMZ3W+/1CqY=",
      "sha256-umDNa5+wEukAb2uOcsXGyk7fH4cAtGIdY/LxD4cAOWs=",
      "sha256-oP0lUXNLVta8iZrBpndNfoYaLUqtOFUepmmF7cSSmKY=",
      "sha256-kFAIUwypIt04FgLyVU63Lcmp2AQimPh/TdYjy04Flxs=",
      "sha256-CKxPDFPrKIw2Ht2LdPlIQKnX2JLCPqqfLJvEfltalpY=",
      "sha256-vEnjl3fZTfqdoswyul3Do5nX1Dv6QnCJUKq7QXyWVN8=",
      "sha256-6Px4n3R6/N/JZ0Mksb8L/02vXYuCkSuF4M4+g55H9j8=",
    ]
  }
}
