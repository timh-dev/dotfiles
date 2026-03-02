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
	filter   string
	filtered []int
	viewport int
	height   int
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
		height:  20,
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
				if m.cursor < m.viewport {
					m.viewport = m.cursor
				}
			}
		case "down", "j":
			visible := len(m.choices)
			if len(m.filtered) > 0 {
				visible = len(m.filtered)
			}
			if m.cursor < visible-1 {
				m.cursor++
				if m.cursor >= m.viewport+m.height {
					m.viewport = m.cursor - m.height + 1
				}
			}
		case "enter", " ":
			if len(m.filtered) > 0 {
				m.selected = m.choices[m.filtered[m.cursor]]
			} else {
				m.selected = m.choices[m.cursor]
			}
			return m, tea.Quit
		case "backspace":
			if len(m.filter) > 0 {
				m.filter = m.filter[:len(m.filter)-1]
				m.cursor = 0
				m.viewport = 0
				m.updateFilter()
			}
		default:
			if len(msg.String()) == 1 {
				m.filter += msg.String()
				m.cursor = 0
				m.viewport = 0
				m.updateFilter()
			}
		}
	}
	return m, nil
}

func (m *model) updateFilter() {
	if m.filter == "" {
		m.filtered = nil
		return
	}
	lower := strings.ToLower(m.filter)
	m.filtered = nil
	for i, choice := range m.choices {
		if strings.Contains(strings.ToLower(choice), lower) {
			m.filtered = append(m.filtered, i)
		}
	}
}

func (m model) View() string {
	s := titleStyle.Render("Select an option")
	if m.filter != "" {
		s += lipgloss.NewStyle().Foreground(lipgloss.Color("#82AAFF")).Render(" [filter: " + m.filter + "]")
	}
	s += "\n\n"
	
	displayIndices := m.filtered
	if len(displayIndices) == 0 {
		displayIndices = make([]int, len(m.choices))
		for i := range displayIndices {
			displayIndices[i] = i
		}
	}
	
	start := m.viewport
	end := m.viewport + m.height
	if end > len(displayIndices) {
		end = len(displayIndices)
	}
	
	for i := start; i < end; i++ {
		idx := displayIndices[i]
		choice := m.choices[idx]
		if m.cursor == i {
			s += selectedStyle.Render("> " + choice) + "\n"
		} else {
			s += itemStyle.Render("  " + choice) + "\n"
		}
	}
	
	if len(displayIndices) > m.height {
		s += lipgloss.NewStyle().Foreground(lipgloss.Color("#546E7A")).Render(fmt.Sprintf("\n[%d/%d] ", m.cursor+1, len(displayIndices)))
	}
	s += lipgloss.NewStyle().Foreground(lipgloss.Color("#546E7A")).Render("(type to filter, ↑/↓ to move, enter to select, q to quit)")
	
	return s
}

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: qmenu [help|projects|config|bookmarks]")
		os.Exit(1)
	}
	
	switch strings.ToLower(os.Args[1]) {
	case "help":
		runHelp()
	case "projects":
		runProjects()
	case "config":
		runConfig()
	case "bookmarks":
		runBookmarks()
	default:
		fmt.Println("Unknown command. Use: help, projects, config, or bookmarks")
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
	
	p := tea.NewProgram(initialModel(choices), tea.WithAltScreen())
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
			dotfiles := os.Getenv("HOME") + "/dotfiles"
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
	
	p := tea.NewProgram(initialModel(choices), tea.WithAltScreen())
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
	dotfiles := filepath.Join(homeDir, "dotfiles")
	
	if _, err := os.Stat(dotfiles); os.IsNotExist(err) {
		fmt.Printf("Error: Directory does not exist: %s\n", dotfiles)
		return
	}
	
	fmt.Printf("Opening VSCode in: %s\n", dotfiles)
	cmd := exec.Command("code", "-n", dotfiles)
	if err := cmd.Run(); err != nil {
		fmt.Printf("Error opening VSCode: %v\n", err)
	}
}

type bookmark struct {
	title  string
	url    string
	folder string
}

func runBookmarks() {
	homeDir, _ := os.UserHomeDir()
	dbPath := filepath.Join(homeDir, "Library", "Application Support", "zen", "Profiles")
	
	entries, err := os.ReadDir(dbPath)
	if err != nil {
		fmt.Printf("Error finding Zen profile: %v\n", err)
		return
	}
	
	var profilePath string
	for _, entry := range entries {
		if entry.IsDir() && strings.Contains(entry.Name(), "release") {
			profilePath = filepath.Join(dbPath, entry.Name(), "places.sqlite")
			if _, err := os.Stat(profilePath); err == nil {
				break
			}
		}
	}
	if profilePath == "" {
		for _, entry := range entries {
			if entry.IsDir() && strings.Contains(entry.Name(), "Default") {
				profilePath = filepath.Join(dbPath, entry.Name(), "places.sqlite")
				if _, err := os.Stat(profilePath); err == nil {
					break
				}
			}
		}
	}
	
	if profilePath == "" {
		fmt.Println("Could not find Zen browser profile")
		return
	}
	
	tmpDB := "/tmp/zen_places.sqlite"
	src, err := os.Open(profilePath)
	if err != nil {
		fmt.Printf("Error opening database: %v\n", err)
		return
	}
	defer src.Close()
	
	dst, err := os.Create(tmpDB)
	if err != nil {
		fmt.Printf("Error creating temp database: %v\n", err)
		return
	}
	defer dst.Close()
	
	_, err = dst.ReadFrom(src)
	if err != nil {
		fmt.Printf("Error copying database: %v\n", err)
		return
	}
	dst.Close()
	
	cmd := exec.Command("sqlite3", tmpDB, `
WITH RECURSIVE folder_path(id, path) AS (
  SELECT id, title FROM moz_bookmarks WHERE parent = 1
  UNION ALL
  SELECT b.id, fp.path || '/' || b.title 
  FROM moz_bookmarks b JOIN folder_path fp ON b.parent = fp.id
  WHERE b.type = 2
)
SELECT b.title, p.url, COALESCE(fp.path, 'Uncategorized') as folder
FROM moz_bookmarks b 
JOIN moz_places p ON b.fk = p.id
LEFT JOIN folder_path fp ON b.parent = fp.id
WHERE b.type = 1 AND b.title IS NOT NULL
ORDER BY folder, b.title
`)
	output, err := cmd.CombinedOutput()
	if err != nil {
		fmt.Printf("Error querying bookmarks: %v\nOutput: %s\n", err, string(output))
		return
	}
	
	lines := strings.Split(strings.TrimSpace(string(output)), "\n")
	var bookmarks []bookmark
	for _, line := range lines {
		parts := strings.SplitN(line, "|", 3)
		if len(parts) >= 2 {
			folder := "Uncategorized"
			if len(parts) == 3 && parts[2] != "" {
				folder = parts[2]
			}
			bookmarks = append(bookmarks, bookmark{title: parts[0], url: parts[1], folder: folder})
		}
	}
	
	if len(bookmarks) == 0 {
		fmt.Println("No bookmarks found")
		return
	}
	
	browseBookmarks(bookmarks, "")
}

func browseBookmarks(bookmarks []bookmark, currentPath string) {
	folders := make(map[string]bool)
	var choices []string
	var items []bookmark
	
	if currentPath == "" {
		choices = append(choices, "[Search All Bookmarks]")
	} else if currentPath != "__SEARCH__" {
		choices = append(choices, "[.. Back]")
	}
	
	if currentPath == "__SEARCH__" {
		for _, bm := range bookmarks {
			choices = append(choices, bm.title)
			items = append(items, bm)
		}
	} else {
		for _, bm := range bookmarks {
			if strings.HasPrefix(bm.folder, currentPath) {
				remaining := strings.TrimPrefix(bm.folder, currentPath)
				if currentPath != "" && strings.HasPrefix(remaining, "/") {
					remaining = strings.TrimPrefix(remaining, "/")
				}
				
				if remaining == "" {
					choices = append(choices, bm.title)
					items = append(items, bm)
				} else {
					nextFolder := strings.Split(remaining, "/")[0]
					if !folders[nextFolder] {
						folders[nextFolder] = true
						choices = append(choices, nextFolder+"/")
					}
				}
			}
		}
	}
	
	p := tea.NewProgram(initialModel(choices), tea.WithAltScreen())
	m, err := p.Run()
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return
	}
	
	if finalModel, ok := m.(model); ok && finalModel.selected != "" {
		if finalModel.selected == "[Search All Bookmarks]" {
			browseBookmarks(bookmarks, "__SEARCH__")
		} else if finalModel.selected == "[.. Back]" {
			if currentPath == "__SEARCH__" {
				browseBookmarks(bookmarks, "")
			} else {
				parentPath := ""
				if idx := strings.LastIndex(currentPath, "/"); idx > 0 {
					parentPath = currentPath[:idx]
				}
				browseBookmarks(bookmarks, parentPath)
			}
		} else if strings.HasSuffix(finalModel.selected, "/") {
			folder := strings.TrimSuffix(finalModel.selected, "/")
			newPath := currentPath
			if newPath != "" {
				newPath += "/"
			}
			newPath += folder
			browseBookmarks(bookmarks, newPath)
		} else {
			for _, bm := range items {
				if bm.title == finalModel.selected {
					fmt.Printf("Opening: %s\n", bm.url)
					exec.Command("open", bm.url).Run()
					break
				}
			}
		}
	}
}
