# Registration Process

Please follow the procedure outlined below to complete the registration process. The steps should be followed in the given order.

## Execution Scripts

1. `regist_atlas.sh`
2. `template_run.m`
3. `regist_mean.sh`
4. `demonsRegist_run.m`
5. `interp_run.m`

These scripts are located under the `script` path.

Alternatively, you can run the `pipeline_demo.sh` script located under the same `script` path.

```bash
bash pipeline_demo.sh
```

## Output Directories

After executing the above scripts, you will find several directories under `data/G/regist_green` and `data/R/regist_red`. These directories will contain the following:

- `red/green_crop` - This directory contains eyes cropped red/green image in `.mat` format.
- `red/green_crop_MIPs` - This directory contains the maximum intensity projections in three directions of the eyes cropped images.
- `red/green_demons` - This directory contains demons registered red/green images in `.mat` format.
- `red/green_demons_MIPs` - This directory contains the maximum intensity projections in three directions of the demons registered images.

Please ensure to follow the steps correctly to avoid any issues during the registration process.

## Dependency

<details open>
<summary> Tool </summary>

[CMTK 3.3.1](https://www.nitrc.org/projects/cmtk)

</details>
