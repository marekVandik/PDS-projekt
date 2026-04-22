#!/bin/python3

import pandas as pd
import matplotlib.pyplot as plt

def plot_df(df):
    pass

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

    #print(data)
    df = pd.DataFrame.from_dict(data)
    df = df[df['sid'] == df['sid'].mode()[0]]
    print(df)

    df['time'] = (df['time'] - df['time'].iloc[0]) / 1000000000

    ax = df.plot(x='time', y='cwnd')
    fig = ax.get_figure()
    fig.savefig('./results/' + quic_filename + '-cwnd.svg')

    df['acked_diff'] = df['acked'].diff()
    df['time_diff'] = df['time'].diff()
    df['mbps_rate'] = (df['acked_diff'] / df['time_diff']) * 8 / (1024 * 1024)
    df['mbps_rate'] = df['mbps_rate'].ewm(span=10).mean()
    #df['mbps_rate'] = df['mbps_rate'].ewm(span=30).mean()

    ax = df.plot(x='time', y='mbps_rate')
    fig = ax.get_figure()
    fig.savefig('./results/' + quic_filename + '-rate.svg')



def plot_tcp(tcp_filename):
    df = pd.read_csv('./results/' + tcp_filename, sep=',')
    df = df[df['sport'] == 80]
    #print(df)

    max_port = df['dport'].mode()[0]
    #print(max_port)

    df = df[df["dport"] == max_port]
    #print(df)

    df['time'] = (df['time'] - df['time'].iloc[0]) / 1000000000

    ax = df.plot(x='time', y='cwnd')
    fig = ax.get_figure()
    fig.savefig('./results/' + tcp_filename + '-cwnd.svg')

    df['una_diff'] = df['una'].diff()
    una_diff_wrap = df['una_diff'] < 0
    una_diff_correction = df['una_diff'].copy()
    una_diff_correction[una_diff_wrap] += 2 ** 32
    df['time_diff'] = df['time'].diff()
    df['mbps_rate'] = (una_diff_correction / df['time_diff']) * 8 / (1024 * 1024)
    df['mbps_rate'] = df['mbps_rate'].ewm(span=10).mean()
    #df['mbps_rate'] = df['mbps_rate'].ewm(span=30).mean()

    ax = df.plot(x='time', y='mbps_rate')
    fig = ax.get_figure()
    fig.savefig('./results/' + tcp_filename + '-rate.svg')



def main():
    plot_tcp('BBR-WIFI')
    plot_tcp('RENO-WIFI')
    plot_tcp('CUBIC-WIFI')
    plot_quic('QUIC-WIFI')

if __name__ == "__main__":
    main()
