#!/bin/bash

/geckodriver --port=4444 &

/wait && /usr/local/bin/backend
