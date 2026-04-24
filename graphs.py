#!/bin/python3

import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

def plot_cwnd(df, title, filename):
    df['time_s'] = df['time'] / (10 ** 9)

    plt.figure()
    ax = sns.lineplot(data=df, x='time_s', y='cwnd')
    ax.set_title(title)
    ax.set_xlabel('time')
    fig = ax.get_figure()
    fig.savefig('./results/' + filename + '-cwnd.svg')
    plt.close(fig)


# expects 'acked' column
def plot_goodput(df, title, filename):
    # resample for every ms
    df['time'] = pd.to_datetime(df['time'], unit='ns')
    df = df.set_index('time')
    df = df.resample('ms').first().interpolate()
    df['time'] = df.index.astype('int64') / (10 ** 9)
    df = df.reset_index(drop=True)

    # resolution to every 20 ms
    df_small = df.groupby(df.index // 20).agg({
        'time': 'first',
        'acked': 'first'
    }).reset_index(drop=True)
    df = df_small

    df['dt'] = df['time'].diff()
    df['da'] = df['acked'].diff()

    # correction for bpf probe - una is u32 and overflows on some occasios
    da_wrap = df['da'] < 0
    da_correction = df['da'].copy()
    da_correction[da_wrap] += 2 ** 32

    df['mbps'] = (da_correction / df['dt']) * 8 / (1024 * 1024)
    mean_mbps = df['mbps'].mean()

    plt.figure()
    ax = sns.lineplot(data=df, x='time', y='mbps')
    ax.set_title(title)
    ax.axhline(mean_mbps, color='orange', linestyle='--', label=f'avg goodput = {mean_mbps:.2f} Mbps')
    ax.legend()
    fig = ax.get_figure()
    fig.savefig('./results/' + filename + '-rate.svg')
    plt.close(fig)

def plot_quic(quic_filename):
    data = {}
    with open('./results/' + quic_filename, 'r') as file:
        for line in file:
            pre = line.split('quic_probe_start|')
            if len(pre) != 2:
                continue

            post = pre[1].split('|quic_probe_end')
            if len(post) != 2:
                continue

            extracted = post[0].split(',')
            for e in extracted:
                kv = e.split(':')
                if len(kv) != 2:
                    continue

                data.setdefault(kv[0], []).append(int(kv[1]))

    df = pd.DataFrame.from_dict(data)
    df = df[df['sid'] == df['sid'].mode()[0]]
    df = df.dropna()

    df['time'] = df['time'] - df['time'].iloc[0]

    plot_cwnd(df, 'CWND: ' + quic_filename, quic_filename)
    plot_goodput(df, 'Goodput: ' + quic_filename, quic_filename)


def plot_tcp(tcp_filename):
    df = pd.read_csv('./results/' + tcp_filename, sep=',')
    df = df[df['sport'] == 80]

    max_port = df['dport'].mode()[0]

    df = df[df["dport"] == max_port]

    df = df.dropna()

    df['time'] = df['time'] - df['time'].iloc[0]
    df['acked'] = df['una']

    plot_cwnd(df, 'CWND: ' + tcp_filename, tcp_filename)
    plot_goodput(df, 'Goodput: ' + tcp_filename, tcp_filename)


def main():
    plot_tcp('BBR-wifi-topo')
    plot_tcp('RENO-wifi-topo')
    plot_tcp('CUBIC-wifi-topo')
    plot_quic('QUIC-wifi-topo')

    plot_tcp('BBR-baseline-topo')
    plot_tcp('RENO-baseline-topo')
    plot_tcp('CUBIC-baseline-topo')
    plot_quic('QUIC-baseline-topo')

    plot_tcp('BBR-geo-topo')
    plot_tcp('RENO-geo-topo')
    plot_tcp('CUBIC-geo-topo')
    #plot_quic('QUIC-geo-topo')

    plot_tcp('BBR-bloat-topo')
    plot_tcp('RENO-bloat-topo')
    plot_tcp('CUBIC-bloat-topo')
    plot_quic('QUIC-bloat-topo')

if __name__ == "__main__":
    main()
