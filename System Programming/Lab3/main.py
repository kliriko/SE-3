import math
import re
import pandas as pd
import requests
from typing import Dict, List, Optional, Tuple, Any


# ============================================================================
# МОДУЛЬ 1: ПРЕПРОЦЕСИНГ ТЕКСТУ
# ============================================================================
class TextPreprocessor:
    """Модуль підготовки тексту до аналізу"""

    @staticmethod
    def preprocess(text: str) -> str:
        """Нормалізація тексту"""
        # Нормалізація пробілів
        text = re.sub(r'\s+', ' ', text).strip()

        # Уніфікація одиниць вимірювання
        text = text.replace('см.', 'см').replace('°', ' градусів')

        # Додавання пробілів навколо чисел та одиниць
        text = re.sub(r'(\d+)\s*(см|градус)', r'\1 \2', text)

        # Видалення зайвих крапок перед "Знайти"
        text = re.sub(r'\.\s*Знайти', ' Знайти', text)

        return text


# ============================================================================
# МОДУЛЬ 2: АНАЛІЗ ТЕКСТУ (UDPipe 2.12)
# ============================================================================
class UDPipeAnalyzer:
    """Модуль морфосинтаксичного аналізу та витягування структур"""

    API_URL = "https://lindat.mff.cuni.cz/services/udpipe/api/process"
    MODEL = "ukrainian-iu-ud-2.12-230717"

    @classmethod
    def parse(cls, text: str) -> str:
        """Отримання CoNLL-U розбору від UDPipe"""
        payload = {
            "data": text,
            "model": cls.MODEL,
            "tokenizer": "",
            "tagger": "",
            "parser": ""
        }
        try:
            resp = requests.post(cls.API_URL, data=payload, timeout=20)
            resp.raise_for_status()
            return resp.json()["result"]
        except Exception as e:
            print(f"⚠ Помилка UDPipe: {e}")
            return ""

    @staticmethod
    def parse_conllu(conllu: str) -> List[List[Dict[str, Any]]]:
        """Розбір CoNLL-U на речення з токенами"""
        sentences = []
        current = []

        for line in conllu.split("\n"):
            line = line.strip()

            if not line or line.startswith("#"):
                if current:
                    sentences.append(current)
                    current = []
                continue

            fields = line.split("\t")
            if len(fields) >= 10 and fields[0].isdigit():
                current.append({
                    "id": int(fields[0]),
                    "form": fields[1].lower(),
                    "lemma": fields[2].lower(),
                    "upos": fields[3],
                    "head": int(fields[6]) if fields[6].isdigit() else 0,
                    "deprel": fields[7]
                })

        if current:
            sentences.append(current)

        return sentences


# ============================================================================
# МОДУЛЬ 3: ЕКСТРАКТОР ЕЛЕМЕНТІВ
# ============================================================================
class GeometryExtractor:
    """Витягування фігур, параметрів та цільових величин"""

    FIGURES = {
        "прямокутник": "rectangle",
        "ромб": "rhombus",
        "трапеція": "trapezoid",
        "паралелограм": "parallelogram"
    }

    PARAMS = {
        "сторона": "сторона",
        "основа": "основа",
        "висота": "висота",
        "кут": "кут",
        "діагональ": "діагональ"
    }

    @classmethod
    def extract_figure(cls, sentences: List[List[Dict]]) -> Optional[str]:
        """Визначення типу геометричної фігури"""
        for sent in sentences:
            for token in sent:
                # Пошук по формі і лемі (для надійності)
                for word in [token["form"], token["lemma"]]:
                    if word in cls.FIGURES:
                        return cls.FIGURES[word]
        return None

    @classmethod
    def extract_target(cls, sentences: List[List[Dict]]) -> Optional[str]:
        """Визначення того, що потрібно знайти"""
        for sent in sentences:
            for i, token in enumerate(sent):
                if token["lemma"] == "знайти":
                    # Шукаємо об'єкт дієслова
                    obj_tokens = [t for t in sent
                                  if t["head"] == token["id"] and
                                  t["deprel"] in ("obj", "obl")]

                    if obj_tokens:
                        obj_token = obj_tokens[0]
                        # Збираємо всю іменну групу з модифікаторами
                        related = [t for t in sent
                                   if t["head"] == obj_token["id"] and
                                   t["deprel"] in ("amod", "nmod")]
                        related.append(obj_token)
                        phrase = " ".join(t["form"] for t in
                                          sorted(related, key=lambda x: x["id"]))
                        return phrase.lower()

                    # Fallback: наступне слово після "знайти"
                    if i + 1 < len(sent):
                        return sent[i + 1]["form"]

        return None

    @classmethod
    def extract_parameters(cls, sentences: List[List[Dict]], original_text: str) -> Dict[str, List[float]]:
        """Витягування числових параметрів фігури"""
        values = {}

        # СТРАТЕГІЯ 1: Regex пошук (найнадійніший)
        cls._extract_with_regex(original_text, values)

        # СТРАТЕГІЯ 2: Аналіз залежностей UDPipe
        for sent in sentences:
            cls._extract_from_dependencies(sent, values)

        return values

    @staticmethod
    def _extract_with_regex(text: str, values: Dict[str, List[float]]):
        """Витягування через регулярні вирази"""
        text = text.lower()

        # Паттерни для різних конструкцій
        patterns = [
            # "сторони 5 см і 12 см"
            (r'сторон[аиіу]?\s+(\d+(?:\.\d+)?)\s+см\s+[іи]\s+(\d+(?:\.\d+)?)\s+см', 'сторона'),
            # "сторона 5 см"
            (r'сторон[аиіу]?\s+(\d+(?:\.\d+)?)\s+см', 'сторона'),

            # "основи 6 см і 10 см"
            (r'основ[аиіу]?\s+(\d+(?:\.\d+)?)\s+см\s+[іи]\s+(\d+(?:\.\d+)?)\s+см', 'основа'),
            # "основа 6 см"
            (r'основ[аиіу]?\s+(\d+(?:\.\d+)?)\s+см', 'основа'),

            # "висота 4 см"
            (r'висот[аиіу]?\s+(\d+(?:\.\d+)?)\s+см', 'висота'),

            # "кут 60 градусів" або "кут 60°"
            (r'кут[аи]?\s+(\d+(?:\.\d+)?)\s*(?:градус|°)', 'кут'),

            # "діагональ 13 см" або "діагоналі 8 см і 6 см"
            (r'діагонал[іьяю]?\s+(\d+(?:\.\d+)?)\s+см\s+[іи]\s+(\d+(?:\.\d+)?)\s+см', 'діагональ'),
            (r'діагонал[іьяю]?\s+(\d+(?:\.\d+)?)\s+см', 'діагональ'),
        ]

        for pattern, param_name in patterns:
            matches = re.finditer(pattern, text)
            for match in matches:
                numbers = [float(g) for g in match.groups() if g]
                if numbers:
                    values.setdefault(param_name, []).extend(numbers)

    @staticmethod
    def _extract_from_dependencies(sentence: List[Dict], values: Dict[str, List[float]]):
        """Витягування через синтаксичні залежності (допоміжний метод)"""
        for token in sentence:
            if token["upos"] == "NOUN" and token["lemma"] in GeometryExtractor.PARAMS:
                param_name = GeometryExtractor.PARAMS[token["lemma"]]

                # Шукаємо всі числа, пов'язані з цим іменником
                for num_token in sentence:
                    if num_token["upos"] == "NUM":
                        # Пряма залежність або через одиницю виміру
                        if (num_token["head"] == token["id"] or
                                any(t["id"] == num_token["head"] and
                                    t["head"] == token["id"]
                                    for t in sentence)):
                            try:
                                num = float(num_token["form"])
                                if param_name not in values:
                                    values[param_name] = []
                                if num not in values[param_name]:
                                    values[param_name].append(num)
                            except ValueError:
                                pass


# ============================================================================
# МОДУЛЬ 4: ОНТОЛОГІЯ ПЛАНІМЕТРІЇ (Таксономічна ієрархія)
# ============================================================================
class GeometricFigure:
    """Базовий клас для геометричних фігур"""

    @staticmethod
    def calculate(params: Dict[str, List[float]], target: str) -> Optional[float]:
        """Розрахунок шуканої величини"""
        raise NotImplementedError


class Rectangle(GeometricFigure):
    """Прямокутник: a, b - сторони; d - діагональ"""

    @staticmethod
    def calculate(params: Dict[str, List[float]], target: str) -> Optional[float]:
        sides = params.get("сторона", [])
        diag = params.get("діагональ", [])

        a = sides[0] if len(sides) > 0 else None
        b = sides[1] if len(sides) > 1 else None
        d = diag[0] if diag else None

        # Периметр
        if "периметр" in target and a and b:
            return 2 * (a + b)

        # Площа
        if "площ" in target and a and b:
            return a * b

        # Діагональ
        if "діагональ" in target and a and b:
            return round(math.sqrt(a ** 2 + b ** 2), 2)

        # Друга сторона (з діагоналі та однієї сторони)
        if "сторон" in target and d and a:
            return round(math.sqrt(d ** 2 - a ** 2), 2)

        return None


class Rhombus(GeometricFigure):
    """Ромб: a - сторона; d1, d2 - діагоналі; α - кут"""

    @staticmethod
    def calculate(params: Dict[str, List[float]], target: str) -> Optional[float]:
        side = params.get("сторона", [None])[0]
        diagonals = params.get("діагональ", [])
        angles = params.get("кут", [])

        # Площа через діагоналі
        if "площ" in target and len(diagonals) >= 2:
            return round(diagonals[0] * diagonals[1] / 2, 2)

        # Площа через сторону та кут
        if "площ" in target and side and angles:
            return round(side ** 2 * math.sin(math.radians(angles[0])), 2)

        # Сторона через діагоналі
        if "сторон" in target and len(diagonals) >= 2:
            return round(math.sqrt((diagonals[0] / 2) ** 2 + (diagonals[1] / 2) ** 2), 2)

        # Радіус вписаного кола
        if "радіус" in target and side:
            if len(diagonals) >= 2:
                area = diagonals[0] * diagonals[1] / 2
            elif angles:
                area = side ** 2 * math.sin(math.radians(angles[0]))
            else:
                return None
            return round(area / (2 * side), 2)

        return None


class Trapezoid(GeometricFigure):
    """Трапеція: a, b - основи; h - висота"""

    @staticmethod
    def calculate(params: Dict[str, List[float]], target: str) -> Optional[float]:
        bases = sorted(params.get("основа", []))
        height = params.get("висота", [None])[0]

        # Площа
        if "площ" in target and len(bases) >= 2 and height:
            return round((bases[0] + bases[1]) / 2 * height, 2)

        # Середня лінія
        if "середн" in target and len(bases) >= 2:
            return round((bases[0] + bases[1]) / 2, 2)

        return None


class Parallelogram(GeometricFigure):
    """Паралелограм: a, b - сторони; h - висота; α - кут"""

    @staticmethod
    def calculate(params: Dict[str, List[float]], target: str) -> Optional[float]:
        sides = params.get("сторона", [])
        angles = params.get("кут", [])
        height = params.get("висота", [None])[0]

        a = sides[0] if len(sides) > 0 else None
        b = sides[1] if len(sides) > 1 else None

        # Площа через сторони та кут
        if "площ" in target and a and b and angles:
            return round(a * b * math.sin(math.radians(angles[0])), 2)

        # Площа через основу та висоту
        if "площ" in target and a and height:
            return round(a * height, 2)

        # Висота через сторону та кут
        if "висот" in target and b and angles:
            return round(b * math.sin(math.radians(angles[0])), 2)

        return None


# ============================================================================
# МОДУЛЬ 5: ГОЛОВНИЙ РОЗВ'ЯЗУВАЧ
# ============================================================================
class GeometrySolver:
    """Інтеграція всіх модулів для розв'язання задач"""

    FIGURE_CLASSES = {
        "rectangle": Rectangle,
        "rhombus": Rhombus,
        "trapezoid": Trapezoid,
        "parallelogram": Parallelogram
    }

    def __init__(self):
        self.preprocessor = TextPreprocessor()
        self.analyzer = UDPipeAnalyzer()
        self.extractor = GeometryExtractor()

    def solve(self, text: str, verbose: bool = True) -> Optional[float]:
        """Повний цикл розв'язання задачі"""
        if verbose:
            print(f"\n{'=' * 70}")
            print(f"ТЕКСТ: {text}")
            print('=' * 70)

        # Крок 1: Препроцесинг
        processed_text = self.preprocessor.preprocess(text)
        if verbose:
            print(f"Препроцесинг: {processed_text}")

        # Крок 2: UDPipe аналіз
        conllu = self.analyzer.parse(processed_text)
        if not conllu:
            if verbose:
                print("⚠ Помилка парсингу UDPipe")
            return None

        sentences = self.analyzer.parse_conllu(conllu)

        # Крок 3: Витягування компонентів
        figure = self.extractor.extract_figure(sentences)
        target = self.extractor.extract_target(sentences)
        params = self.extractor.extract_parameters(sentences, processed_text)

        if verbose:
            print(f"Фігура: {figure or '—'}")
            print(f"Параметри: {params}")
            print(f"Знайти: {target or '—'}")

        # Крок 4: Валідація
        if not figure or not target:
            if verbose:
                print("⚠ Не вдалося розпізнати фігуру або ціль")
            return None

        # Крок 5: Обчислення через онтологію
        figure_class = self.FIGURE_CLASSES.get(figure)
        if not figure_class:
            if verbose:
                print(f"⚠ Невідома фігура: {figure}")
            return None

        result = figure_class.calculate(params, target)

        if verbose:
            print(f"{'─' * 70}")
            print(f"✓ ВІДПОВІДЬ: {result}")
            print('=' * 70)

        return result


# ============================================================================
# ТЕСТУВАННЯ
# ============================================================================
if __name__ == "__main__":
    # Банк задач
    tasks = [
        "У прямокутнику сторони 5 см і 12 см. Знайти периметр.",
        "У ромбі сторона 10 см, кут 60°. Знайти площу.",
        "У трапеції основи 6 см і 10 см, висота 4 см. Знайти площу.",
        "У паралелограмі сторони 8 см і 6 см, кут 30°. Знайти площу.",
        "У прямокутнику діагональ 13 см, сторона 5 см. Знайти сторону.",
        "У ромбі діагоналі 8 см і 6 см. Знайти сторону.",
        "У трапеції основи 5 см і 9 см, висота 3 см. Знайти середню лінію.",
        "У паралелограмі сторони 7 см і 9 см, кут 45°. Знайти висоту.",
        "У ромбі сторона 5 см, кут 90°. Знайти радіус вписаного кола.",
        "У трапеції основи 4 см і 8 см, висота 5 см. Знайти площу.",
    ]

    expected = [34, 86.6, 32, 24, 12, 5, 7, 6.36, 2.5, 30]

    # Створення Excel файлу
    pd.DataFrame({"Задача": tasks, "Очікувана відповідь": expected}).to_excel(
        "bank_zadach_improved.xlsx", index=False
    )
    print("✓ Файл bank_zadach_improved.xlsx створено\n")

    # Тестування
    solver = GeometrySolver()
    results = []

    for i, (task, exp) in enumerate(zip(tasks, expected), 1):
        result = solver.solve(task, verbose=True)

        if result is None:
            status = "❌ ПОМИЛКА"
        elif abs(result - exp) < 0.1:
            status = "✓ OK"
        else:
            status = f"⚠ НЕТОЧНІСТЬ (очікувано {exp})"

        results.append({"Задача": task, "Результат": result, "Очікувано": exp, "Статус": status})
        print(f"\n{status}\n")

    # Звіт
    print("\n" + "=" * 70)
    print("ПІДСУМКОВИЙ ЗВІТ")
    print("=" * 70)
    df_results = pd.DataFrame(results)
    print(df_results[["Результат", "Очікувано", "Статус"]].to_string(index=False))

    success_rate = sum(1 for r in results if "OK" in r["Статус"]) / len(results) * 100
    print(f"\n✓ Успішність: {success_rate:.1f}%")