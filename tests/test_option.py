import pandas as pd

from hypothesis import given
from ape_risk import strategies


def hist_data():
    df = pd.read_csv("notebook/data/prices.csv")
    df['price0_rel'] = df['price0'] / df['price0'].iloc[0]
    df['price1_rel'] = df['price1'] / df['price1'].iloc[0]
    return df.filter(items=['price0_rel', 'price1_rel']).to_numpy().tolist()


@given(strategies.multi_gbms(
    initial_value=1.0,
    num_points=4320,
    num_rvs=2,
    params=[0, 1],
    scale=[[1, 0], [0, 1]],
    shift=[0, 0],
    hist_data=hist_data(),
))
def test_option_triggers(simulated_prices):
    print("simulated_prices:", simulated_prices)
