import numpy
import coremltools
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split
import pandas as pd
from sklearn.metrics import mean_squared_error


task_descriptions = ["Finish math homework",
                      "Finish english homework",
                        "Finish pyschology homework",
                        "Finish the quarterly report",
                        "Submit expense report"]
task_completion_times = [20, 30, 10, 900, 90]

# consider clean data by removing words like finish
vectorizer = TfidfVectorizer()
tf_id_matrix = vectorizer.fit_transform(task_descriptions)
x_train, x_test, y_train, y_test = train_test_split(tf_id_matrix, task_completion_times, test_size=0.2, random_state=42)
regresison_model = LinearRegression()
regresison_model.fit(x_train, y_train)
y_pred = regresison_model.predict(x_test)
mse = mean_squared_error(y_test, y_pred)
print(mse)
