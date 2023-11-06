from typing import List, Dict


def llama2_chat(turns: List[Dict], 
               system_prompt="You are a helpful, respectful and honest assistant. Always answer as helpfully as possible, while being safe. Your answers should not include any harmful, unethical, racist, sexist, toxic, dangerous, or illegal content. Please ensure that your responses are socially unbiased and positive in nature.\n\nIf a question does not make any sense, or is not factually coherent, explain why instead of answering something not correct. If you don’t know the answer to a question, please don’t share false information."
               ):
    # Expects the user and assistant turns to alternate
    segments = [f"<s>[INST] <<SYS>>\n{system_prompt}\n<</SYS>>\n\n"]
    for turn in turns:
        if turn["speaker"] == "user":
            segments.append(f"[INST] {turn['text']} [/INST] ")
        elif turn["speaker"] == "assistant":
            segments.append(f"{turn['text']}</s><s> ")

    return "".join(segments)


def em_german_chat(turns: List[Dict], system_prompt="Du bist ein hilfreicher Assistent. "):
    # Expects the user and assistant turns to alternate
    segments = [system_prompt]
    for turn in turns:
        if turn["speaker"] == "user":
            segments.append(f"USER: {turn['text']} ")
        elif turn["speaker"] == "assistant":
            segments.append(f"ASSISTANT: {turn['text']} ")

    return "".join(segments)


def em_german_rag(turns: List[Dict], 
                  system_prompt="Du bist ein hilfreicher Assistent. Für die folgende Aufgabe stehen dir zwischen den tags BEGININPUT und ENDINPUT mehrere Quellen zur Verfügung. Metadaten zu den einzelnen Quellen wie Autor, URL o.ä. sind zwischen BEGINCONTEXT und ENDCONTEXT zu finden, danach folgt der Text der Quelle. Die eigentliche Aufgabe oder Frage ist zwischen BEGININSTRUCTION und ENDINCSTRUCTION zu finden. Beantworte diese wortwörtlich mit einem Zitat aus den Quellen. Sollten diese keine Antwort enthalten, antworte, dass auf Basis der gegebenen Informationen keine Antwort möglich ist! USER:\n"
                  ):
    # Expects a series of search results and then the question to be in the last turn
    segments = [system_prompt]
    for turn in turns:
        if turn["speaker"] == "context":
            metadata = []
            if "metadata" in turn:
                for key, value in turn["metadata"].items():
                    metadata.append(f"{key}: {value}")
            metadata = "\n".join(metadata)
            segments.append(f"""BEGININPUT\nBEGINCONTEXT\n{metadata}\nENDCONTEXT\n{turn['text']}\nENDINPUT\n""")
        elif turn["speaker"] == "question":
            segments.append(f"BEGININSTRUCTION\n{turn['text']} Gebe die Quelle mit an!\nENDINSTRUCTION\nASSISTANT:\n")
            break

    return "".join(segments)


if __name__ == "__main__":
    turns = [
        {"speaker": "context", "text": "Die Hauptstadt Deutschlands ist Berlin"},
        {"speaker": "context", "text": "zwei plus zwei ist fünf", "metadata": {"Url": "https://www.wikipedia.com/math"}},
        {"speaker": "question", "text": "Was ist zwei plus zwei?"},
    ]
    print(em_german_rag(turns))