package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

type model struct {
	choices  []string
	cursor   int
	selected string
}

var (
	titleStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("#FFCB6B")).
			Bold(true)
	
	itemStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("#89DDFF"))
	
	selectedStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("#C3E88D")).
			Bold(true)
)

func initialModel(choices []string) model {
	return model{
		choices: choices,
	}
}

func (m model) Init() tea.Cmd {
	return nil
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch msg.String() {
		case "ctrl+c", "q", "esc":
			return m, tea.Quit
		case "up", "k":
			if m.cursor > 0 {
				m.cursor--
			}
		case "down", "j":
			if m.cursor < len(m.choices)-1 {
				m.cursor++
			}
		case "enter", " ":
			m.selected = m.choices[m.cursor]
			return m, tea.Quit
		}
	}
	return m, nil
}

func (m model) View() string {
	s := titleStyle.Render("Select an option") + "\n\n"
	
	for i, choice := range m.choices {
		if m.cursor == i {
			s += selectedStyle.Render("> " + choice) + "\n"
		} else {
			s += itemStyle.Render("  " + choice) + "\n"
		}
	}
	
	s += "\n" + lipgloss.NewStyle().Foreground(lipgloss.Color("#546E7A")).Render("(↑/↓ to move, enter to select, q to quit)")
	
	return s
}

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: qmenu [help|projects|config]")
		os.Exit(1)
	}
	
	switch strings.ToLower(os.Args[1]) {
	case "help":
		runHelp()
	case "projects":
		runProjects()
	case "config":
		runConfig()
	default:
		fmt.Println("Unknown command. Use: help, projects, or config")
		os.Exit(1)
	}
}

func runHelp() {
	choices := []string{
		"Git Aliases",
		"Docker Aliases",
		"Python Aliases",
		"AWS Aliases",
		"Terraform Aliases",
		"NPM Aliases",
		"System Aliases",
		"All Aliases",
	}
	
	p := tea.NewProgram(initialModel(choices))
	m, err := p.Run()
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		os.Exit(1)
	}
	
	if finalModel, ok := m.(model); ok && finalModel.selected != "" {
		var dfArg string
		switch finalModel.selected {
		case "Git Aliases":
			dfArg = "git"
		case "Docker Aliases":
			dfArg = "docker"
		case "Python Aliases":
			dfArg = "python"
		case "AWS Aliases":
			dfArg = "aws"
		case "Terraform Aliases":
			dfArg = "terraform"
		case "NPM Aliases":
			dfArg = "npm"
		case "System Aliases":
			dfArg = "system"
		case "All Aliases":
			dfArg = "help"
		}
		
		if dfArg != "" {
			dotfiles := os.Getenv("HOME") + "/Documents/development/personal/dotfiles"
			filePath := dotfiles + "/aliases/" + dfArg + ".zsh"
			
			content, err := os.ReadFile(filePath)
			if err != nil {
				fmt.Printf("File not found: %s\n", filePath)
				return
			}
			
			fmt.Print(string(content))
		}
	}
}

func runProjects() {
	homeDir, _ := os.UserHomeDir()
	projectDir := filepath.Join(homeDir, "Documents", "development")
	
	browseDirectory(projectDir)
}

func browseDirectory(dir string) {
	entries, err := os.ReadDir(dir)
	if err != nil {
		fmt.Printf("Error reading directory: %v\n", err)
		return
	}
	
	var choices []string
	choices = append(choices, "[Open in VSCode]", "[Go Back]")
	
	for _, entry := range entries {
		if entry.Name()[0] == '.' {
			continue
		}
		if entry.IsDir() {
			choices = append(choices, entry.Name()+"/")
		}
	}
	
	p := tea.NewProgram(initialModel(choices))
	m, err := p.Run()
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return
	}
	
	if finalModel, ok := m.(model); ok && finalModel.selected != "" {
		switch finalModel.selected {
		case "[Open in VSCode]":
			fmt.Printf("Opening %s in VSCode...\n", dir)
			exec.Command("code", dir).Run()
		case "[Go Back]":
			parent := filepath.Dir(dir)
			if parent != dir {
				browseDirectory(parent)
			}
		default:
			newPath := filepath.Join(dir, strings.TrimSuffix(finalModel.selected, "/"))
			browseDirectory(newPath)
		}
	}
}

func runConfig() {
	homeDir, _ := os.UserHomeDir()
	dotfiles := filepath.Join(homeDir, "Documents", "development", "personal", "dotfiles")
	
	fmt.Printf("Opening VSCode in: %s\n", dotfiles)
	exec.Command("code", dotfiles).Run()
}
