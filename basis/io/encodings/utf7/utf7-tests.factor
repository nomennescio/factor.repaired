USING:
    io.encodings.string io.encodings.utf7
    kernel
    sequences
    strings
    tools.test ;
IN: io.encodings.utf7.tests

[
    {
        "~/b&AOU-g&APg-"
        "b&AOU-x"
        "b&APg-x"
        "test"
        "Skr&AOQ-ppost"
        "Ting &- S&AOU-ger"
        "~/F&APg-lder/mailb&AOU-x &- stuff + more"
        "~peter/mail/&ZeVnLIqe-/&U,BTFw-"
    }
] [
    {
        "~/bågø"
        "båx"
        "bøx"
        "test"
        "Skräppost"
        "Ting & Såger"
        "~/Følder/mailbåx & stuff + more"
        "~peter/mail/日本語/台北"
    } [ utf7imap4 encode >string ] map
] unit-test
