# Calaverita Generator

Add an AI agent to a Flutter app, one small step at a time.

The app writes a funny, rhyming "literary skull" (a *calaverita*) about a friend
or coworker from a name, a job and a tone, and draws a sugar-skull portrait to
go with it. You start with a plain Flutter app and end with an agent that fills
the form, dresses the skull and shows the finished calaverita in the chat, using
the [CopilotKit Flutter SDK](https://github.com/VGVentures/copilotkit_flutter_sdk).

Built with Flutter on the web, [Very Good Engineering](https://verygood.ventures)
and Feature-First Clean Architecture.

## The steps

Each folder is a complete, runnable snapshot. Every step starts from the one
before it, so compare two folders to see exactly what changed.

| Folder | What the app does | What you learn |
| --- | --- | --- |
| [`00-foundations`](00-foundations) | The app with local state and no agent. You fill the form, dress the skull and press a button. | The architecture: a domain, a data and a presentation package per feature. |
| [`01-shared-state`](01-shared-state) | A copilot panel appears. You tell it about your friend and it fills the form and dresses the skull. | **Shared state**: `AgentStateBuilder`, `patchSharedState` and `setSharedState`. |
| [`02-generative-ui`](02-generative-ui) | You ask for the calaverita and the agent writes it: a card with the skull appears in the chat and the verse shows under the skull on the stage. | **Generative UI**: a frontend tool registered with `CopilotTool` whose builder renders a widget. |
| [`03-custom-server`](03-custom-server) | The same app, talking to a small server of its own instead of the built-in agent. *Optional.* | **Server logic**: validating what the agent changes and shaping its prompt. |

## Set up

You need:

- [FVM](https://fvm.app). The repository pins Flutter 3.47.0 in `.fvmrc`, and the
  SDK needs Dart 3.13 or later.
- Node.js 20 or later, for the runtime.
- An [Anthropic API key](https://console.anthropic.com).
- Chrome.

```sh
fvm install
```

> [!NOTE]
> The CopilotKit Flutter SDK is not on pub.dev yet, so each snapshot gets it from
> GitHub, pinned to one commit (see `dependency_overrides` in the `pubspec.yaml`
> at the root of each snapshot). Your first `pub get` needs access to
> [`VGVentures/copilotkit_flutter_sdk`](https://github.com/VGVentures/copilotkit_flutter_sdk).

## Run a step

The app talks to a *Copilot Runtime*, a small server that sits between the app
and the model. Steps 01 and 02 use the one in [`runtime/`](runtime); step 03 has
its own.

**1. Start the runtime** (steps 01 and 02) in a first terminal:

```sh
cp runtime/.env.example runtime/.env
# open runtime/.env and set ANTHROPIC_API_KEY=<your key>
./runtime/start.sh
```

It prints `http://localhost:8200/api/copilotkit`. Check it with
`curl http://localhost:8200/api/copilotkit/info`.

> [!IMPORTANT]
> The key lives only in `runtime/.env` (git-ignored) or in your shell. Never
> commit it.

To use another model, set `COPILOTKIT_MODEL` in `runtime/.env`. The default is
`anthropic:claude-sonnet-5-5`.

**2. Run the app** in a second terminal. `00-foundations` needs no runtime.

```sh
cd 01-shared-state            # or 00-foundations, 02-generative-ui
fvm flutter pub get
cd apps/calaverita_app
fvm flutter run -d chrome
```

### What to try

- **00:** type a name and a job, pick a tone, put a sombrero on the skull and
  press **Write my calaverita**.
- **01:** in the copilot panel, write *"Ana is a pilot, make it sarcastic"*. The
  details fill in and the skull gets dressed. Then edit a field by hand and ask
  *"who is this for?"*: the agent sees your edit. The **Shared state** is the
  one thing the form, the skull and the agent all read and write.
- **02:** write *"Mario is a chef, dramatic please. Write his calaverita!"*. The
  agent writes four lines: a card with the skull portrait appears in the chat,
  and the same verse shows under the skull on the stage. (The **Write my
  calaverita** button still uses the offline template.)
- **03:** in the first terminal (it uses port 4100, so the runtime can keep
  running):

  ```sh
  cd 03-custom-server/server
  cp .env.example .env          # set ANTHROPIC_API_KEY
  npm install
  npm start                     # http://localhost:4100/api/copilotkit
  ```

  and run the app from `03-custom-server` as above. This server checks every
  change the agent makes to the form and tells the model what it rejected, so it
  can fix it and try again. `npm run smoke` runs those checks offline, with no
  key.

## Point the app at another backend

The runtime URL is set in **one place per snapshot**:
`apps/calaverita_app/lib/app/app_config.dart`. To use a hosted backend, change
`AppConfig.defaultRuntimeUrl`, or run with
`--dart-define=RUNTIME_URL=<url>`.

## How the code is organized

Each step is a Dart workspace of small packages:

```
apps/calaverita_app/               composes the features into an app
features/calaverita/
  calaverita_domain/               models and the repository interface
  calaverita_data/                 the offline template that writes the verse
  calaverita_presentation/         the screen, the cubit and the skull portrait
features/assistant/
  assistant_presentation/          the chat (from step 01)
shared/app_ui/                     the design system
```

A presentation package never imports a data package, and a feature never reaches
into another feature's internals. Run `fvm flutter analyze` and
`fvm flutter test` inside a snapshot, and `fvm dart test` in the domain and data
packages.

## Keep building

- Give the skull more parts: a beard, a different pattern, a bandana. Add the SVG
  and the variant in `SkullPart`, and teach the agent in the prompt.
- Let the agent ask before it guesses, with a human-in-the-loop tool
  (`CopilotHumanInTheLoop`): *"make it fancier"* could offer three options.
- Replace the template repository with a call to the agent, so the *Write my
  calaverita* button uses the model too.
- Save the calaverita as an image, or share it.
- Move the step 03 server somewhere public and point `AppConfig` at it.

## Troubleshooting

- **"The copilot could not answer"**: the app can't reach the runtime. Check that
  it is running and that the URL in `app_config.dart` matches the one it printed.
- **The runtime starts but every message fails**: the model or the key is wrong.
  Send a run straight to the runtime and read the `RUN_ERROR` event (see the
  [SDK example README](https://github.com/VGVentures/copilotkit_flutter_sdk/blob/main/example/README.md#troubleshooting)).
- **`pub get` can't fetch the SDK**: you need access to the SDK repository.

---

Leading a team that wants to ship AI features in Flutter? Talk to
[Very Good Ventures](https://verygood.ventures).
