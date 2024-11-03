import gradio as gr
import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from pathlib import Path

df = pd.read_excel(
    Path(__file__).parent / "default of credit card clients.xls",
    skiprows=1,
    index_col=0,
    dtype=np.int32,
)  # all int cols

# remove rows with invalid feature values
df = df[df["EDUCATION"] != 0]
df = df[df["SEX"] != 0]

pay_cols = [f"PAY_{0 if n == 1 else n}" for n in range(1, 7)]
df["PAY_AVG"] = df[pay_cols].mean(axis=1)
df["PAY_MEDIAN"] = df[pay_cols].median(axis=1)
df["PAY_MIN"] = df[pay_cols].min(axis=1)
df["PAY_MAX"] = df[pay_cols].max(axis=1)

bill_amt_cols = [f"BILL_AMT{n}" for n in range(1, 7)]
df["BILL_AMT_AVG"] = df[bill_amt_cols].mean(axis=1)
df["BILL_AMT_MEDIAN"] = df[bill_amt_cols].median(axis=1)
df["BILL_AMT_MIN"] = df[bill_amt_cols].min(axis=1)
df["BILL_AMT_MAX"] = df[bill_amt_cols].max(axis=1)

pay_amt_cols = [f"PAY_AMT{n}" for n in range(1, 7)]
df["PAY_AMT_AVG"] = df[pay_amt_cols].mean(axis=1)
df["PAY_AMT_MEDIAN"] = df[pay_amt_cols].median(axis=1)
df["PAY_AMT_MIN"] = df[pay_amt_cols].min(axis=1)
df["PAY_AMT_MAX"] = df[pay_amt_cols].max(axis=1)

col_selections = [
    "BILL_AMT_MAX",
    "PAY_AMT_MIN",
    "LIMIT_BAL",
    "PAY_MAX",
    "PAY_0",
    "default payment next month",
]

# fit on all data unlike notebook
x = df[col_selections].drop(columns=["default payment next month"])
y = df[col_selections]["default payment next month"]

classifier = RandomForestClassifier(
    n_estimators=1000, warm_start=True, criterion="log_loss", random_state=42, n_jobs=-1
).fit(x, y)

print("Done training")

def predict(*args):
    print(str(args))
    prob = 1-classifier.predict_proba(pd.DataFrame((args,), columns=col_selections[:-1]))
    return f"{prob[0][0]:.2}% probability of default next month"


demo = gr.Interface(
    fn=predict,
    inputs=[gr.Number(label=s) for s in col_selections[:-1]],
    outputs="textbox",
)

demo.launch(share=True)
