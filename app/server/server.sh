#!/bin/bash

#Build for web
flutter build web

# Stop any program currently running on the set port NOTE: I don't think this works
echo 'preparing port' $PORT '...'
fuser -k 5000/tcp

# switch directories
cd build/web/

# Start the server
echo 'Server starting on port' $PORT '...'
python3 -m http.server $PORT
