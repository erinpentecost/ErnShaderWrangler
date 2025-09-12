# Shader Wrangler

This is an OpenMW that will dynamically enable or disable shaders based on FPS performance. It ships with a paired-down tonemap shader that works on GLES devices.

## Installing

Download the [latest version here](https://github.com/erinpentecost/ErnShaderWrangler/archive/refs/heads/main.zip).

Extract to your `mods/` folder. In your `openmw.cfg` file, add these lines in the correct spots:

```ini
data="/wherevermymodsare/mods/ErnShaderWrangler-main"
content=ErnShaderWrangler.omwscripts
```

If you're using this mod, you're probably playing OpenMW on a limited-resource device. If so, make these changes to your `settings.cfg`:

```ini
[Post Processing]
enabled = true
chain =
```

This disables always-on post-processing shaders, but enables post processing to work for dynamically enabled shaders.
