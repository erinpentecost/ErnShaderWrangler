# Shader Wrangler

This is an OpenMW mod that will dynamically enable or disable shaders based on FPS performance. It ships with a paired-down tonemap shader that works on GLES devices.

## Configuring Shaders

Specify shaders by providing a comma-separated list of shader names, like this: `bright,smaa`. You can also set *dynamic float* parameters for the shader like this: `bright(ExposureBias=1.2),smaa`. The shader parameter needs `static = false;` to be set in the parameter in order to be controlled like this.

## Installing

Download the [latest version here](https://github.com/erinpentecost/ErnShaderWrangler/archive/refs/heads/main.zip).

Extract to your `mods/` folder. In your `openmw.cfg` file, add these lines in the correct spots:

```ini
data="/wherevermymodsare/mods/ErnShaderWrangler-main"
content=ErnShaderWrangler.omwscripts
```

Also, make sure this is set in your `settings.cfg`:

```ini
[Post Processing]
enabled = true
```
