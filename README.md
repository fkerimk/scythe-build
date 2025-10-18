# SCYTHE <img width="24" height="24" alt="icon" src="https://fkerimk.com/scythe/icon.png" /> build

A simple fish script for building the Scythe.

> [!CAUTION]  
> Support for the Windows is no longer available.

> [!NOTE]  
> You can take a Windows build directly from Linux, you just can’t build from Windows.

## 🛠 License

scythe-build is licensed under the [LGPL-2.1 license](./LICENSE).

## How to use?

Make sure you have the .NET 10 SDK packages installed.

Builder is only available for the fish shell.

```bash
git clone --recurse-submodules https://github.com/fkerimk/scythe.git
cd scythe
build/build.fish
```