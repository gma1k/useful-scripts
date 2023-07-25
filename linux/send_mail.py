#!/usr/bin/env python

import smtplib
import sys

GMAIL_SMTP_SERVER = "smtp.gmail.com"
GMAIL_SMTP_PORT = 587

GMAIL_EMAIL = "Your Gmail Email Goes Here"
GMAIL_PASSWORD = "Your Gmail Password Goes Here"

def initialize_smtp_server():
    smtpserver = smtplib.SMTP(GMAIL_SMTP_SERVER, GMAIL_SMTP_PORT)
    smtpserver.ehlo()
    smtpserver.starttls()
    smtpserver.ehlo()
    smtpserver.login(GMAIL_EMAIL, GMAIL_PASSWORD)
    return smtpserver

def send_thank_you_mail(email):
    to_email = email
    from_email = GMAIL_EMAIL
    subj = "Thanks for being an active commenter"
    header = "To:%s\nFrom:%s\nSubject:%s \n" % (to_email,
            from_email, subj)
    msg_body = """
    Hi %s,

    Thank you very much for your repeated comments on our service.
    The interaction is much appreciated.

    Thank You.""" % email
    content = header + "\n" + msg_body
    smtpserver = initialize_smtp_server()
    smtpserver.sendmail(from_email, to_email, content)
    smtpserver.close()

if __name__ == "__main__":
    for email in sys.stdin.readlines():
            send_thank_you_mail(email)
