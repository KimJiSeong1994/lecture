# ================================================= [ setting ] ========================================================
# pip install git+https://github.com/haven-jeon/PyKoSpacing.git
# pip install git+https://github.com/ssut/py-hanspell.git
import itertools
import pandas as pd
import networkx as nx
from tqdm import  tqdm
import matplotlib.pyplot as plt
from wordcloud import WordCloud

from konlpy.tag import Komoran
from hanspell import spell_checker # 띄어쓰기 + 맞춤법 보정 패키지
text_df = pd.read_csv("./Crawling_total.txt", sep = "|", encoding = "utf-8").iloc[:, 1:]

# ============================================== [ def. function ] =====================================================
def preprocessing(text_df) :
    text_df["text"] = text_df["title"] + " " + text_df["content"] # 주제 분석, 연관어 분석을 위해 게시글 제목과, 내용 합치기
    text_df["text"] = text_df["text"].str.replace("\\n{1,}", "") # '\n' 줄바꿈 표시 제거
    text_df["text"] = text_df["text"].str.replace("\\s{1, }", "\\s") # 띄어쓰기가 2번 이상인 것을 띄어쓰기 1번으로 변경
    text_df["text"] = text_df["text"].str.replace("[^a-zA-Z가-힣0-9 ]", "") # 영어 대소문자, 한글, 숫자 띄어쓰기 제외한 문자 제거
    text_df["text"] = text_df["text"].str.replace("http.+", "") # url 제거
    text_df["text"] = text_df["text"].apply(lambda x : spell_checker.check(x).checked)

    processed_data = []
    for sentence in tqdm(text_df["text"]) :
        komoran = Komoran()
        tag = komoran.pos(sentence)  # 형태소 처리 ["단어", "품사"]
        nouns = [s for s, t in tag if t in ['SL', 'NNG', 'NNP'] and len(s) > 1]
        # 명사 태그 추출, 한글자 이상만 추출 # nng : 명사 nnp :  고유대명사 sl : 외래어
        processed_data.append(nouns)
    return processed_data

processed_data = preprocessing(text_df.iloc[0:200, :]) # total process time : 36m @@;;

# ======================================= [ Count Vectorization + wordcloud ] ==========================================
from collections import Counter
word_cnt = Counter(list(itertools.chain(*processed_data)))
wc = WordCloud(font_path = "/Users/gimjiseong/Library/Fonts/Typo_DodamM.ttf",background_color = "white", max_font_size = 100)
cloud = wc.generate_from_frequencies(word_cnt)
cloud.to_file('./WordCloud_example.jpg')
plt.show()

# ======================================================= [ N-gram ] ===================================================
from nltk import ngrams
terms_bigram = [list(ngrams(snt, 2)) for snt in processed_data]
bigrams = Counter(list(itertools.chain(*terms_bigram)))

# ============================================= [ N-gram Visualization ] ===============================================
bigram_df = pd.DataFrame(bigrams, columns = ['bigram', 'count'])
d = bigram_df.set_index('bigram').T.to_dict('records')
G = nx.Graph()
for k, v in d[0].items() :
    G.add_edge(k[0], k[1], weight = (v * 10))

fig, ax = plt.subplots(figsize = (10, 8))
pos = nx.spring_layout(G, k = 2)
nx.draw_networkx(G, pos, font_size = 16, width = 3, edge_color = 'grey', node_color = 'purple', with_labels = False, ax = ax)
for key, value in pos.items() :
    x, y = value[0] + .135, value[1] + .045
    ax.text(x, y, s = key, bbox = dict(facecolor = 'red', alpha = 0.25), horizontalalignment = 'center', fontsize = 13)

plt.savefig("./bigrame_graph_Example.jpg")