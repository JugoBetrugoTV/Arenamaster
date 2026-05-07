# Contributing to Arenamaster

Thank you for your interest in contributing to Arenamaster!

## Code of Conduct

By participating, you agree to maintain respectful, professional communication.

---

## How to Contribute

### Reporting Bugs

1. **Check existing issues** - Don't duplicate
2. **Provide details:**
   - WoW version (must be 12.0.5)
   - Addon version (check `/am help`)
   - Step-by-step reproduction
   - Expected vs actual behavior
   - Screenshots if applicable

3. **Include environment:**
   - Other addons enabled
   - Hardware specs if relevant
   - Error messages from `/console reloadui`

### Suggesting Features

1. **Check documentation** - May already exist
2. **Describe use case** - Why is this useful?
3. **Provide examples** - How would it work?
4. **Discuss implementation** - Any technical concerns?

### Code Contributions

#### Setup Development Environment

```bash
# Clone repository
git clone https://github.com/JugoBetrugoTV/Arenamaster.git
cd Arenamaster

# Create feature branch
git checkout -b feature/your-feature-name
```

#### Development Guidelines

**Code Style:**
- Use 4-space indentation
- Clear variable names
- Comments for complex logic
- Follow existing code patterns

**Module Development:**
1. Determine dependency tier (see MODULE_STRUCTURE.md)
2. Add to Arenamaster_Dependencies.xml
3. Update Arenamaster.toc
4. Initialize in Arenamaster.lua
5. Add documentation

**Testing:**
1. Test in all bracket sizes (2v2, 3v3, 5v5)
2. Test with minimal preset (performance)
3. Test with other popular addons
4. Verify slash commands work

**Documentation:**
- Update README.md if adding features
- Add documentation to docs/ folder
- Update CHANGELOG.md
- Include code comments

#### Git Workflow

```bash
# Create feature branch
git checkout -b feature/description

# Make commits with clear messages
git commit -m "feat: Add new feature

Description of what was added and why."

# Push to your fork
git push origin feature/description

# Create pull request on GitHub
```

**Commit Message Format:**
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `refactor:` - Code refactoring
- `enhance:` - Enhancement
- `perf:` - Performance improvement
- `test:` - Tests

Example:
```
feat: Add focus recommendation cooldown timer

- Shows countdown when next focus target should update
- Includes visual progress bar
- Respects user notification settings
```

---

## Pull Request Process

1. **Before submitting:**
   - Ensure code follows style guide
   - Add/update documentation
   - Test thoroughly
   - Update CHANGELOG.md

2. **PR Description:**
   - Clear description of changes
   - References to related issues
   - Testing performed
   - Screenshots for UI changes

3. **Review Process:**
   - Maintainer reviews code
   - May request changes
   - Ensure backward compatibility
   - Verify no performance impact

4. **Merging:**
   - Squash commits if needed
   - Merge to main branch
   - Close related issues
   - Update release notes

---

## Module Development Guidelines

### Creating New Module

```lua
-- modules/yourmodule.lua

local AM = Arenamaster
local YourModule = {}

-- Initialize
function YourModule:Initialize()
    -- Setup code
end

-- Main functionality
function YourModule:DoSomething()
    -- Implementation
end

-- Export
AM.YourModule = YourModule
return YourModule
```

### Dependency Tiers

- **Tier 0:** No dependencies (foundation)
- **Tier 1:** Depends on Tier 0 (UI/Config)
- **Tier 2:** Depends on Tier 0-1 (Analysis)
- **Tier 3:** Depends on Tier 0-2 (Display)
- **Tier 4:** Depends on Tier 0-2 (AI)

### Adding to TOC

```
## Add to Arenamaster.toc with tier comment

## TIER X: Category
modules/yourmodule.lua
```

### Updating Dependencies

```lua
-- modules/Arenamaster.lua

function AM:Initialize()
    -- ... other modules ...
    self.YourModule:Initialize()
end
```

---

## Performance Guidelines

- Keep modules modular and lightweight
- Use event-driven design, not loops
- Cache data where appropriate
- Profile with `/console report gfxinfo`
- Target <2ms per frame impact

---

## API Usage

All WoW API calls must:
1. Be documented in docs/API_REFERENCE_12.0.5.md
2. Use approved/safe functions
3. Include fallbacks for older patches
4. Not use restricted/tainted APIs

See docs/APPROVED_FUNCTIONS.md for complete reference.

---

## Testing Checklist

Before submitting PR:
- [ ] Code compiles (no syntax errors)
- [ ] Slash commands work (`/am help`)
- [ ] Config window opens (`/am config`)
- [ ] All settings save/load correctly
- [ ] Works in 2v2, 3v3, 5v5
- [ ] No performance regression
- [ ] Tested with Minimal preset
- [ ] Documentation updated
- [ ] CHANGELOG updated
- [ ] No console errors (`/console report`)

---

## Documentation Standards

All documentation should:
- Use clear, simple English
- Include examples where applicable
- Have a "Last Updated" date
- Include version number
- Have proper headings and formatting

---

## Licensing

By contributing, you agree your code is licensed under the same terms as Arenamaster (see LICENSE).

---

## Questions?

- Read [MODULE_STRUCTURE.md](docs/MODULE_STRUCTURE.md) for architecture
- Check [API_REFERENCE_12.0.5.md](docs/API_REFERENCE_12.0.5.md) for WoW APIs
- Review existing modules for examples
- Check CHANGELOG for recent changes

---

**Thank you for contributing to Arenamaster! ⚔️**
