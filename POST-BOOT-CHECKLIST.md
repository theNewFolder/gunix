# Post-Boot Checklist

Follow these steps after the first boot to complete your system setup.

## 1. Login as gux

- At the login prompt, enter the username: `gux`
- Enter the password: `o`
- You should now have access to the user account

## 2. Run guix pull

Update Guix to the latest version:

```bash
guix pull
```

This command will:
- Fetch the latest Guix and package definitions
- Build and install the latest version of Guix
- May take several minutes to complete

Wait for the command to finish before proceeding to the next step.

## 3. Apply guix-home.scm

Configure your home environment using the Guix Home configuration:

```bash
guix home reconfigure guix-home.scm
```

This will:
- Apply your home environment configuration
- Set up shell configuration files
- Install any packages specified in your configuration

## 4. Start dwl-guile

Launch your window manager:

```bash
dwl-guile
```

This starts the dwl-guile window manager with Guile support, allowing you to manage windows and interact with the desktop.

## 5. Configure Emacs

Launch Emacs:

```bash
emacs
```

Once Emacs is running:
- Review your Emacs configuration (typically in `~/.config/emacs` or `~/.emacs.d`)
- Install any required packages or language servers
- Test basic functionality (opening files, running commands)
- Configure any personal preferences (theme, keybindings, etc.)

## 6. Set API Keys for MCP Servers

Configure API keys for Model Context Protocol (MCP) servers:

- Locate your MCP configuration file (typically in `~/.config/claude` or similar)
- Add the following API keys:
  - **Anthropic API Key**: Required for Claude integration
  - **Any service-specific keys**: Depending on which MCP servers you're using

Example configuration location:
```
~/.config/claude/config.json
```

Set each key securely and ensure the file has appropriate permissions (600).

## 7. Test EXWM Integration

If using Emacs with EXWM (Emacs X Window Manager):

- Start EXWM within Emacs:
  ```elisp
  (exwm-enable)
  ```
  Or ensure it's enabled in your Emacs configuration

- Test window management:
  - Open multiple applications using EXWM commands
  - Test window switching with configured keybindings
  - Verify that EXWM can manage both X11 windows and Emacs buffers

- Check integration:
  - Confirm that the taskbar/workspace indicators are working
  - Test workspace switching
  - Verify that window renaming and positioning work correctly

## Verification Checklist

After completing all steps, verify the following:

- [ ] Successfully logged in as gux
- [ ] `guix pull` completed without errors
- [ ] `guix home reconfigure guix-home.scm` applied successfully
- [ ] dwl-guile window manager started
- [ ] Emacs launched and configured properly
- [ ] MCP API keys are set and accessible
- [ ] EXWM is functioning (if applicable)
- [ ] Basic applications launch and respond to commands
- [ ] System is ready for development use

## Troubleshooting

If you encounter any issues:

1. **guix pull errors**: Check your network connection and Guix documentation
2. **guix home reconfigure failures**: Review the error message and check your configuration file syntax
3. **dwl-guile issues**: Verify X11 is running and check for conflicting window managers
4. **Emacs configuration problems**: Check your Emacs configuration files for syntax errors
5. **MCP server issues**: Verify API keys are correctly set and network access is available
6. **EXWM problems**: Check Emacs version compatibility and required dependencies

For more help, consult the respective project documentation or community resources.
