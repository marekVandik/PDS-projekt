# PDS transport analysis

This software analyzes TCP BBR, TCP RENO, TCP CUBIC and QUIC transport protocols using
a simulated network topology in Docker of client - router - server, where the router shapes the traffic and client and server generate traffic of the beforementioned transport algorithms.

It is configurable by adding new ``*-topo.env`` files into the root folder.
By default it simulates baseline network, high loss Wi-Fi network, high RTT Geo network and a Bufferbloat network.

To run the simulation, first, start up Docker and make sure your kernel supports BTF and tcp_bbr module.
Then run the ``./setup.sh`` script which will build the containers.
The script will take quite a bit of time to finish so be patient - approx 10 mins to build patched Nginx.

Then run the simulation using ``./run.sh`` and after some time, cca 20 mins, your results shall be in ``./results/*.svg``.

You can clean your Docker images afterwards using ``./teardown.sh``, note the build of nginx creates quite large
intermediate containers.

You can change the way it gets plotted in ``./graphs.py``. Also there is a convenience script for svg to eps conversion in ``./convert.sh``.
