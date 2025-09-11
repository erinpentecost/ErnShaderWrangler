# Bright

This is a paired-down `tonemap` shader for OpenMW that is enabled or disabled automatically depending on your FPS.


## Installing

Download the [latest version here](https://github.com/erinpentecost/ErnBright/archive/refs/heads/main.zip).

Extract to your `mods/` folder. In your `openmw.cfg` file, add these lines in the correct spots:

```ini
data="/wherevermymodsare/mods/ErnBright-main"
content=ErnBright.omwscripts
```

If you're using this mod, you're probably playing OpenMW on a limited-resource device. If so, make these changes to your `settings.cfg`:

```ini
[Post Processing]
enabled = true
transparent postpass = false
chain =
```

This disables always-on post-processing shaders.
