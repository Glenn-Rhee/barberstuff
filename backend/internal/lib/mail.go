package lib

import (
	"barberstuff_backend/internal/helper"
	"bytes"
	"fmt"
	"html/template"
	"log"
	"os"
	"strconv"

	"github.com/joho/godotenv"
	"gopkg.in/gomail.v2"
)

type SMTPConfig struct {
	Host     string
	Port     int
	Username string
	Password string
	From     string
	FromName string
}

func LoadSMTPConfig() SMTPConfig {
	if _, err := os.Stat(".env"); err == nil {
		if err := godotenv.Load(); err != nil {
			log.Println("Error load dotenv file:", err.Error())
		}
	}

	port, _ := strconv.Atoi(os.Getenv("SMTP_PORT"))

	return SMTPConfig{
		Host:     os.Getenv("SMTP_HOST"),
		Port:     port,
		Username: os.Getenv("SMTP_USERNAME"),
		Password: os.Getenv("SMTP_PASSWORD"),
		From:     os.Getenv("SMTP_FROM_EMAIL"),
		FromName: os.Getenv("SMTP_FROM_NAME"),
	}
}

type EmailOptions struct {
	To           []string
	Cc           []string
	Bcc          []string
	Subject      string
	TemplateName string
	TemplateData map[string]interface{}
	Attachments  []string
}

func SendEmail(cfg SMTPConfig, msg EmailOptions) error {
	body, err := renderTemplate(msg.TemplateName, msg.TemplateData)
	if err != nil {
		helper.Logger("Failed render template", "lib/main.go", err)
		return err
	}

	m := gomail.NewMessage()
	m.SetHeader("From", fmt.Sprintf("%s <%s>", cfg.FromName, cfg.From))
	m.SetHeader("To", msg.To...)

	if len(msg.Cc) > 0 {
		m.SetHeader("Cc", msg.Cc...)
	}

	if len(msg.Cc) > 0 {
		m.SetHeader("Bcc", msg.Bcc...)
	}

	m.SetHeader("Subject", msg.Subject)
	m.SetBody("text/html", body)

	for _, path := range msg.Attachments {
		m.Attach(path)
	}

	dialer := gomail.NewDialer(cfg.Host, cfg.Port, cfg.Username, cfg.Password)

	if err := dialer.DialAndSend(m); err != nil {
		helper.Logger("Failed send email", "lib/mail.go", err)
		return err
	}

	return nil
}

func renderTemplate(templateName string, data map[string]interface{}) (string, error) {
	tmplPath := fmt.Sprintf("templates/mail/%s", templateName)

	tmpl, err := template.ParseFiles(tmplPath)
	if err != nil {
		return "", err
	}

	var buf bytes.Buffer
	if err := tmpl.Execute(&buf, data); err != nil {
		return "", err
	}

	return buf.String(), nil
}

func SendEmailToUser(mailOptions EmailOptions) error {
	cfg := LoadSMTPConfig()

	msg := EmailOptions{
		To:           mailOptions.To,
		Subject:      mailOptions.Subject,
		TemplateName: mailOptions.TemplateName,
		TemplateData: mailOptions.TemplateData,
	}

	return SendEmail(cfg, msg)
}
