# Bord CLI tests

## TODO: add this to docs

!!! Good to know for future: `borg prune -v --keep-daily=7 --keep-weekly=4 --keep-monthly=6 /backup/repo`
And this:

```console
borg create ...
borg prune ...
borg compact
rclone sync /backup/repo remote:photo-backup-bucket/borg
```

```console
rclone sync /mnt/backups/csaladikepek s3:nemeslab-synology-backup/pictures/csaladikepek \
  --s3-chunk-size 64M \
  --s3-upload-concurrency 4 \
  --transfers 4 \
  --checkers 8 \
  --fast-list \
  --progress
```

Before you'd begin, export these variables:

```console
export BORG_PASSPHRASE=<passphrase>
export REPO_NAME=test
export PATH_TO_BACKUP=./pictures
export PATH_TO_BACKUP_LOGS=.
export PATH_TO_TARS=tars
```

Note, that I used the phrase "backup" but in Borg's teminology backups are called archives.

## Create repo

Repository will contain all of the backups you will create. So this is basically a collection of your backups.
Repository can be set up at creation time, you cannot modify it later.

Create a repo:

```console
borg init \
    --encryption repokey \
    $REPO_NAME                  # name of the repo
```

After that export the key with:

```console
borg key export --paper   $REPO_NAME encrypted-key-backup.txt
# Or with
borg key export $REPO_NAME encrypted-key-backup
```

And save the key somewhere safe.

## Create backups

You can create a new backup anytime you want.
Every time you create a backup (a.k.a archive) you need to give a unique name for it. **This archive name must be a valid directory name!**

```console
borg create \
    --list --stats --progress \
    --comment "Weekly family picture and video backup." \
    --compression lzma \
    --files-changed ctime \
    $REPO_NAME::backup-{utcnow} \
    $PATH_TO_BACKUP \
    2>> "$PATH_TO_BACKUP_LOGS/$(date +"%Y-%m-%d-%H%M%S")-logfile.log"
```

> In the archive name, you may use the following placeholders:
> {now}, {utcnow}, {fqdn}, {hostname}, {user} and some others.

## List backups

You can list the repo's backups with the following command:

```console
borg list $REPO_NAME
```

example:

```console
$ borg list $REPO_NAME
backup-2026-03-05T14:11:31           Thu, 2026-03-05 15:11:35 [3f40828fb4283ba50e3d3b5fb6c222d14b3f7a631ed47797267d43f0f073611b]
backup-2026-03-05T14:16:05           Thu, 2026-03-05 15:16:05 [30cc9350f7dfa0a963d3132bd345dc623cbb0b2453f20f381664294a0ee5c20c]
backup-2026-03-05T14:23:05           Thu, 2026-03-05 15:23:05 [2283393ae64471464fb7648cc5c1d7ad797e11b5ee72cb1ed080d1a5e0d02b64]
backup-2026-03-05T14:27:45           Thu, 2026-03-05 15:27:45 [38e6c6dfe228d77c24e01ff2ff6ac42cf1530c3f855b382141facffaf1242630]
backup-2026-03-05T14:28:01           Thu, 2026-03-05 15:28:01 [7560c7953113ea6d91022c230b84b4dccbc42f1e5d1c577437b9982aec996ae4]

# Format:
<name-of-the-backup>                 <backup-creation-time>   [archive-id]
```

Format is:

- Name of the backup

## Diff of two backups

```console
export BACKUP1_NAME=backup-2026-03-05T14:11:31
export BACKUP2_NAME=backup-2026-03-05T14:16:05
borg diff --content \
    $REPO_NAME::$BACKUP1_NAME $BACKUP2_NAME
```

## Info of a backup

```console
export BACKUP_NAME=backup-2026-03-05T14:16:05
borg info $REPO_NAME::$BACKUP_NAME
```

## Extract (restore) backup

In order to restore data from a specific backup you can use the following command.
Note, that all data will be restored from the backup by default, but you can limit the data to restore by path and patterns.

```console
export BACKUP_NAME=backup-2026-03-05T14:36:47
borg extract --list \
    $REPO_NAME::$BACKUP_NAME
```

## Compact repo

If a backup is not finished successfully, the repo and already existing backups are fine and healthy. But some chunks could stayed in the repo from the interrupted backup process.
To get rid of them use the following command:

```console
borg compact $REPO_NAME
```

## Export tar

Export archive contents as a tarball.

```console
export BACKUP_NAME=backup-2026-03-05T14:36:47
borg export-tar --list \
    $REPO_NAME::$BACKUP_NAME $PATH_TO_TARS/$(date +"%Y-%m-%d-%H%M%S").tbz
```
## Import tar

This command creates a backup archive from a tarball.

```console
export TAR_NAME=tars/2026-03-05-160719.tbz
borg import-tar \
    --list --stats \
    $REPO_NAME::import-from-tar-$(date +"%Y-%m-%d-%H%M%S") $TAR_NAME
```
