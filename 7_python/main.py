#!/usr/bin/env python3
import functools
from typing import List, Dict, Callable


def read_file_to_lines() -> List[str]:
    with open('inputs/input', 'r') as file:
        return file.readlines()


def has_n_same(n: int) -> Callable[[Dict[str, int]], bool]:
    def compare_counts(card_counts: Dict[str, int]) -> bool:
        return max(card_counts.values()) == n

    return compare_counts


def has_n_and_m_same(n: int, m: int) -> Callable[[Dict[str, int]], bool]:
    def compare_counts(card_counts: Dict[str, int]) -> bool:
        return sorted(card_counts.values())[-2:] == sorted([n, m])

    return compare_counts


hand_type_strength_list = [
    # five of a kind
    has_n_same(5),
    # four of a kind
    has_n_same(4),
    # full house
    has_n_and_m_same(3, 2),
    # three of a kind
    has_n_same(3),
    # two pair
    has_n_and_m_same(2, 2),
    # one pair
    has_n_same(2),
    # high card
    lambda card_counts: True
]


class Hand:
    def __init__(self, cards: List[str], bet: int):
        self.cards = cards
        self.bet = bet
        self.type_strength = len(hand_type_strength_list) - self._get_hand_type()

    def get_card_counts(self) -> Dict[str, int]:
        return {card: self.cards.count(card) for card in self.cards}

    def _get_hand_type(self) -> int:
        card_counts = self.get_card_counts()
        for i, hand_type in enumerate(hand_type_strength_list):
            if hand_type(card_counts):
                return i
        raise Exception("This should never happen")


def parse_file(lines: List[str]) -> List[Hand]:
    hands = []
    for line in lines:
        cards, bet = line.strip().split()
        hands.append(Hand(list(cards), int(bet)))
    return hands


card_strength_list = [str(i) for i in range(2, 10)] + ['T', 'J', 'Q', 'K', 'A']


def card1_less_powerful(card1: str, card2: str) -> int:
    return card_strength_list.index(card1) - card_strength_list.index(card2)


def hand1_less_powerful(hand1: Hand, hand2: Hand) -> int:
    if hand1.type_strength == hand2.type_strength:
        for i in range(0, len(hand1.cards)):
            cmp = card1_less_powerful(hand1.cards[i], hand2.cards[i])
            if cmp != 0:
                return cmp
    return hand1.type_strength - hand2.type_strength


def sort_hands(hands: List[Hand]) -> None:
    hands.sort(key=functools.cmp_to_key(hand1_less_powerful))


def points(hands: List[Hand]) -> int:
    point = 0
    for i, hand in enumerate(hands):
        point += hand.bet * (i + 1)
    return point


def main():
    lines = read_file_to_lines()
    hands = parse_file(lines)
    sort_hands(hands)

    point = points(hands)
    print(f"First part: {point}")


if __name__ == '__main__':
    main()
