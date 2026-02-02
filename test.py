from bgg_api import BGGClient

print(BGGClient.search_game("Catan")[:3])

game = BGGClient.get_game_details(13)
print(game)
