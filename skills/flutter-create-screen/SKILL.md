---
name: flutter-create-screen
description: Generate a screen (view + widgets) from a Figma node URL (read via the Figma MCP server), or a pasted CSS + screenshot fallback, or a written spec. Use when building, generating, or scaffolding a screen from a design or mockup.
---

# Create screen

Generate Flutter view + widgets from design assets.

## Architecture

Before creating UI, constants, dialogs, or shared helpers, call the Skill tool with `flutter-core-architecture`. Reuse what it lists; do not invent parallel dialogs, text widgets, or theme constants.

## Required context

- **Feature name** in snake_case
- **Feature PascalCase**
- **Design source**: primary — a **Figma node URL** read via the Figma MCP server. Fallback — a pasted CSS dump / screenshot / written spec when no Figma access is available.

Where there is no design source, or it leaves a decision open, call the Skill tool with
`flutter-design` for that decision rather than settling it in the first draft.

## Design token extraction

For a Figma node URL, pull design data with the Figma MCP server before building the table:

- `get_variable_defs` → named design tokens (colors, spacing, typography) → map to `AppColors` / `AppDimensions` / `AppTextStyles`
- `get_design_context` → CSS-like styling + structure for the node
- `get_screenshot` → the rendered image to verify the build against
- `get_metadata` → the node/layer tree

When no Figma URL is available, fall back to the pasted CSS dump.

Build this table before writing code:

| Token | Design value | Flutter value |
|-------|--------------|---------------|
| Background | `#FFFFFF` | `AppColors.background` |
| Primary text size | `16px` | `AppTextStyles.bodyMedium` |
| Padding (h) | `16px` | `AppDimensions.gapM` |
| Padding (v) | `12px` | `AppDimensions.gapS` |
| Border radius | `12px` | `AppDimensions.radiusCard` |
| Font family | `Inter` | constant in `AppTextStyles` |

### Figma variable → Flutter constant (from `get_variable_defs`)

Map every named Figma variable to a constant before touching raw values:

| Figma variable | Value | Flutter constant |
|----------------|-------|------------------|
| `color/background` | `#FFFFFF` | `AppColors.background` |
| `color/text-muted` | `rgba(0,0,0,0.5)` | `AppColors.textMuted` |
| `space/md` | `16px` | `AppDimensions.spaceMd` |
| `radius/card` | `12px` | `AppDimensions.radiusCard` |
| `type/body` | `16px / 500` | `AppTextStyles.bodyMedium` |

### Mapping `get_design_context` output → Flutter

`get_design_context` returns CSS-like values; map any remaining raw values not covered by a named variable:

| CSS property | Flutter |
|--------------|---------|
| `padding: 16px` | `EdgeInsets.all(AppDimensions.gapM)` (when symmetric, use `.symmetric`) |
| `border-radius: 12px` | `BorderRadius.circular(AppDimensions.radiusCard)` |
| `font-size: 16px` | A named `AppTextStyles` entry, unscaled |
| `font-weight: 500` | `FontWeight.w500` |
| `gap: 8px` | `SizedBox(height: AppDimensions.gapS)` between Column children |
| `background: #FFF` | `color: AppColors.background` (extract constant) |
| `color: rgba(0,0,0,0.5)` | encode alpha into hex: `Color(0x80000000)` |
| `box-shadow: 0 2 4 rgba(...)` | `BoxShadow(offset: Offset(0, 2), blurRadius: 4, color: ...)` |
| `display: flex; flex-direction: row` | `Row(...)` |
| `display: flex; flex-direction: column` | `Column(...)` |
| `justify-content: space-between` | `MainAxisAlignment.spaceBetween` |
| `align-items: center` | `CrossAxisAlignment.center` |
| `width: 100%` | `double.infinity` or `Expanded` in flex parent |

Extract every recurring color/size to `AppColors` / `AppDimensions`.

## Screen wiring

Call the Skill tool with `project-conventions` for the Logic seam row, then read the matching
template for how the page provides state and how the view reads it.

| Logic seam | Template |
|---|---|
| `Bloc<Event, State>` | [templates/bloc.md](templates/bloc.md) |
| `Notifier` / `AsyncNotifier` | [templates/riverpod.md](templates/riverpod.md) |
| `ChangeNotifier` | [templates/provider.md](templates/provider.md) |

Every template has the same three-part split, and it is the part worth keeping whichever stack you
are in: a **page** that owns the state object's lifetime and the route name, a private **view** that
rebuilds, and a **content** widget that takes data as a plain constructor argument. Content built
that way pumps in a widget test with no state layer at all, which is what makes rung 3 cheap.

## Widget extraction

Move reusable pieces to `lib/features/{feature}/widget/`:

```dart
// {feature}_card.dart
class {Feature}Card extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const {Feature}Card({
    super.key,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.gapM),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        ),
        child: TextWidget(title, style: AppTextStyles.bodyMedium()),
      ),
    );
  }
}
```

## Form handling

```dart
class _{Feature}Form extends StatefulWidget {
  const _{Feature}Form();

  @override
  State<_{Feature}Form> createState() => _{Feature}FormState();
}

class _{Feature}FormState extends State<_{Feature}Form> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      // dispatch the submit action, in whichever seam the project uses
      _submit(context, _nameController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CommonTextField(
            controller: _nameController,
            validator: (v) => (v?.isEmpty ?? true) ? AppStrings.fieldRequired : null,
          ),
          const SizedBox(height: AppDimensions.gapM),
          CustomButton(onPressed: _onSubmit, label: AppStrings.submit),
        ],
      ),
    );
  }
}
```

## Rules

Barrel imports, the shared component set, the snackbar helpers, the router conventions and the
constants families belong to `flutter-core-architecture`; call it rather than working from a copy.
The templates above already follow it, so read `lib/core/` and swap in whatever the project actually
has before writing a primitive of your own. What is specific to this layer:

- Every dimension resolves to an `AppDimensions` token, in the sizing strategy
  `docs/agents/project.md` names. Font sizes stay unscaled so OS text scaling reaches them.
- Every colour, string and asset path resolves to an `App*` constant, so a rebrand or a copy change
  is one edit in one file.
- `const` constructors wherever the analyzer accepts one.
- Break the build into private `_Widget` classes. A method returning a `Widget` rebuilds the whole
  parent and cannot be `const`.
- After an `await` in a callback: `if (!context.mounted) return;`.
- Dispose every controller the widget created.
- Comments explain non-obvious layout. The class name already says what the widget is.

## Completion criteria

The screen is done when every state the state layer can emit has a branch in the tree, including loading,
empty and failure, and the render matches the design source. State which token in the map has no
`App*` constant yet and what you added, and name any state the design did not specify that you had
to invent. For what belongs inside a state the design never drew, call the Skill tool with
`flutter-design`.
