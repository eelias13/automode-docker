# build and run the docker continer

```bash
sudo docker build . -t automode # --no-cache
sudo docker run -v ./output/:/app/data -v ./output/results:/app/PonyGE2/results automode
```

then you can inspect the [sqlite](https://www.sqlite.org/index.html) database in `output/data.db`

## env variables explant for `config.toml`

- `NUM_OF_EXPERIMENT` this is how often the experiment should run (on one controller)  
- `SAVE_PROBABILITY` the probability when the controller ant ist metics get saved
- `SWARM_MODE_DIST` a variable for the *Swarm mode index* metrics
- `DENSITY_RADIUS`  a variable for the *Average local density* metrics
- `AUTOMODE_EXE` this in the path to the internal automode binary **[don't change]**
- `SCENARIO` this is the path to the scenario file **[don't change]**
- `EXPERIMENT_LEN` this is the length of the simulation **[don't change]**
- `DB_PATH` the path to the database **[don't change]**